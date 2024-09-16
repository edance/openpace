defmodule SqueezeWeb.GarminIntegrationController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Garmin

  def request(conn, %{"provider" => "garmin"}) do
    params = Garmin.Auth.request_token!()

    conn
    |> put_session(:garmin_token_secret, params["oauth_token_secret"])
    |> redirect(external: Garmin.Auth.authorize_url!(params))
  end

  def callback(conn, params) do
    %{"oauth_token" => token, "oauth_verifier" => verifier} = params
    token_secret = get_session(conn, :garmin_token_secret)
    opts = [verifier: verifier, token: token, token_secret: token_secret]
    %{"oauth_token" => token, "oauth_token_secret" => token_secret} = Garmin.Auth.get_token!(opts)
    %{"userId" => uid} = Garmin.Auth.get_user!(token: token, token_secret: token_secret)
    credential_params = %{provider: "garmin", token: token, token_secret: token_secret, uid: uid}

    case Accounts.create_credential(conn.assigns.current_user, credential_params) do
      {:ok, credential} ->
        redirect_current_user(conn, credential)

      {:error, _} ->
        conn
        |> put_flash(:error, "Authentication failed for garmin")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  defp redirect_current_user(conn, credential) do
    load_history(credential)

    conn
    |> put_flash(:info, "Connected to #{credential.provider}")
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  def load_history(_), do: nil
end

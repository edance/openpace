defmodule SqueezeWeb.GarminIntegrationController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller for Garmin authentication integration.
  """

  alias Squeeze.Accounts
  alias Squeeze.Garmin
  alias Squeeze.Reporter
  alias SqueezeWeb.Plug.Auth

  def request(conn, _) do
    params = Garmin.Auth.request_token!()

    conn
    |> put_session(:garmin_token_secret, params["oauth_token_secret"])
    |> redirect(external: Garmin.Auth.authorize_url!(params))
  end

  def callback(conn, %{"oauth_token" => token, "oauth_verifier" => verifier}) do
    token_secret = get_session(conn, :garmin_token_secret)
    opts = [verifier: verifier, token: token, token_secret: token_secret]
    %{"oauth_token" => token, "oauth_token_secret" => token_secret} = Garmin.Auth.get_token!(opts)
    %{"userId" => uid} = Garmin.Auth.get_user!(token: token, token_secret: token_secret)
    credential_params = %{provider: "garmin", token: token, token_secret: token_secret, uid: uid}

    cond do
      user = Accounts.get_user_by_credential(credential_params) ->
        sign_in_and_redirect(conn, user, credential_params)

      conn.assigns[:current_user] ->
        connect_and_redirect(conn, credential_params)

      true ->
        create_user_and_redirect(conn, credential_params)
    end
  end

  defp redirect_current_user(conn, credential) do
    load_history(credential)

    conn
    |> put_flash(:info, "Connected to #{credential.provider}")
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  # Garmin no longer allows you to get user profile data
  defp user_attrs(_credential_params) do
    %{
      user_prefs: %{
        imperial: false,
        rename_activities: false,
        gender: :prefer_not_to_say
      }
    }
  end

  defp connect_and_redirect(conn, credential_params) do
    user = conn.assigns.current_user

    case Accounts.create_credential(user, credential_params) do
      {:ok, _credentials} ->
        redirect_current_user(conn, credential_params)

      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.home_path(conn, :index))
    end
  end

  defp sign_in_and_redirect(conn, user, credential_params) do
    credential = Enum.find(user.credentials, &(&1.provider == "garmin"))
    {:ok, _credential} = Accounts.update_credential(credential, credential_params)

    conn
    |> Auth.sign_in(user)
    |> redirect_current_user(credential_params)
  end

  defp create_user_and_redirect(conn, credential_params) do
    user_params = user_attrs(credential_params)

    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, _credentials} <- Accounts.create_credential(user, credential_params) do
      Reporter.report_new_user(user)

      conn
      |> Auth.sign_in(user)
      |> redirect_current_user(credential_params)
    else
      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.home_path(conn, :namer))
    end
  end

  def load_history(_), do: nil
end

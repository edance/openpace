defmodule SqueezeWeb.IntegrationController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias OAuth2.Client
  alias Squeeze.Accounts
  alias Squeeze.Fitbit.Auth
  alias Squeeze.Garmin

  @strava_auth Application.compile_env(:squeeze, :strava_auth)

  def request(conn, %{"provider" => "garmin"}) do
    params = Garmin.Auth.request_token!()
    conn
    |> put_session(:garmin_token_secret, params["oauth_token_secret"])
    |> redirect(external: Garmin.Auth.authorize_url!(params))
  end

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => "garmin", "oauth_token" => token, "oauth_verifier" => verifier}) do
    token_secret = get_session(conn, :garmin_token_secret)
    opts = [verifier: verifier, token: token, token_secret: token_secret]
    %{"oauth_token" => token, "oauth_token_secret" => token_secret} = Garmin.Auth.get_token!(opts)
    %{"userId" => uid} = Garmin.Auth.get_user!([token: token, token_secret: token_secret])
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

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    credential_params = get_credential!(provider, client)
    case Accounts.create_credential(conn.assigns.current_user, credential_params) do
      {:ok, credential} ->
        setup_integration(conn, client, provider)
        redirect_current_user(conn, credential)
      {:error, _} ->
        conn
        |> put_flash(:error, "Authentication failed for #{provider}")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  defp redirect_current_user(conn, credential) do
    load_history(credential)
    conn
    |> put_flash(:info, "Connected to #{credential.provider}")
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  defp setup_integration(conn, client, "fitbit") do
    user = conn.assigns.current_user
    url = "/1/user/-/activities/apiSubscriptions/#{user.id}.json"
    Client.post!(client, url)
  end
  defp setup_integration(_, _, _), do: nil

  defp authorize_url!("strava") do
    scope = "read,activity:read_all,activity:write"
    @strava_auth.authorize_url!(scope: scope)
  end

  defp authorize_url!("fitbit") do
    scope = "activity heartrate profile weight location"
    Auth.authorize_url!(scope: scope, expires_in: 31_536_000)
  end

  defp get_token!("strava", code) do
    @strava_auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_token!("fitbit", code) do
    Auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_credential!("strava", %{token: token} = client) do
    user = @strava_auth.get_athlete!(client)
    token
    |> Map.take([:access_token, :refresh_token])
    |> Map.merge(%{provider: "strava", uid: "#{user.id}"})
  end

  defp get_credential!("fitbit", client), do: Auth.get_credential!(client)

  def load_history(%{provider: "strava", uid: id}) do
    credential = Accounts.get_credential("strava", id)
    Task.start(fn -> Squeeze.Strava.HistoryLoader.load_recent(credential) end)
  end

  def load_history(%{provider: "fitbit", uid: id}) do
    credential = Accounts.get_credential("fitbit", id)
    Task.start(fn -> Squeeze.Fitbit.HistoryLoader.load_recent(credential) end)
  end

  def load_history(_), do: nil
end

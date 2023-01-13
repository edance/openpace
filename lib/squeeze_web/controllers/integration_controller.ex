defmodule SqueezeWeb.IntegrationController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts

  @strava_auth Application.compile_env(:squeeze, :strava_auth)

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
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

  defp setup_integration(_, _, _), do: nil

  defp authorize_url!("strava") do
    scope = "read,activity:read_all,activity:write"
    @strava_auth.authorize_url!(scope: scope)
  end

  defp get_token!("strava", code) do
    @strava_auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_credential!("strava", %{token: token} = client) do
    user = @strava_auth.get_athlete!(client)
    token
    |> Map.take([:access_token, :refresh_token])
    |> Map.merge(%{provider: "strava", uid: "#{user.id}"})
  end

  def load_history(%{provider: "strava", uid: id}) do
    credential = Accounts.get_credential("strava", id)
    Task.start(fn -> Squeeze.Strava.HistoryLoader.load_recent(credential) end)
  end

  def load_history(_), do: nil
end

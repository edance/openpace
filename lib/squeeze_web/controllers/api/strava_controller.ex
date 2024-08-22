defmodule SqueezeWeb.Api.StravaController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Strava.HistoryLoader

  @strava_auth Application.compile_env(:squeeze, :strava_auth)

  def exchange_code(conn, %{"code" => code}) do
    user = conn.assigns.current_user
    client = get_token!(code)
    athlete = get_athlete!(client)
    params = credential_params(client, athlete)

    with {:ok, credential} <- Accounts.create_credential(user, params),
         {:ok, _} <- Accounts.update_user(user, user_params(athlete)) do
      load_activity_history(credential)

      conn
      |> put_status(:created)
      |> render("credential.json", %{credential: credential})
    end
  end

  defp get_token!(code) do
    @strava_auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_athlete!(client) do
    @strava_auth.get_athlete!(client)
  end

  defp user_params(athlete) do
    %{
      avatar: athlete.profile,
      city: athlete.city,
      state: athlete.state,
      country: athlete.country
    }
  end

  defp load_activity_history(%{provider: "strava", uid: id}) do
    credential = Accounts.get_credential("strava", id)
    Task.start(fn -> HistoryLoader.load_recent(credential) end)
  end

  defp credential_params(%{token: token}, athlete) do
    token
    |> Map.take([:access_token, :refresh_token])
    |> Map.merge(%{provider: "strava", uid: "#{athlete.id}"})
  end
end

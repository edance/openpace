defmodule SqueezeWeb.Api.StravaController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  @strava_auth Application.get_env(:squeeze, :strava_auth)

  def exchange_code(conn, %{"code" => code}) do
    user = conn.assigns.current_user
    client = get_token!(code)
    credential_params = get_credential!(client)
    with {:ok, credential} <- Accounts.create_credential(user, credential_params) do
      conn
      |> put_status(:created)
      |> render("credential.json", %{credential: credential})
    end
  end

  defp get_token!(code) do
    @strava_auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_credential!(%{token: token} = client) do
    user = @strava_auth.get_athlete!(client)
    token
    |> Map.take([:access_token, :refresh_token])
    |> Map.merge(%{provider: "strava", uid: "#{user.id}"})
  end
end

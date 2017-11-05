defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    user_params = get_user!(provider, client)
    case Accounts.get_or_create_user_by_credential(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: activity_path(conn, :index))
      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:info, "Didn't Work")
        |> redirect(to: "/")
    end
  end

  defp authorize_url!("strava") do
    Strava.Auth.authorize_url!(scope: "public")
  end

  defp authorize_url!(_) do
    raise "No matching provider available"
  end

  defp get_token!("strava", code) do
    Strava.Auth.get_token!(code: code)
  end

  defp get_token!(_, _) do
    raise "No matching provider available"
  end

  defp get_user!("strava", client) do
    token = client.token.access_token
    user = Strava.Auth.get_athlete!(client)
    credential = %{provider: "strava", uid: user.id, token: token}
    user
    |> Map.from_struct
    |> Map.merge(%{first_name: user.firstname, last_name: user.lastname, avatar: user.profile})
    |> Map.merge(%{credential: credential})
  end
end

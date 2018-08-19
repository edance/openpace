defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller

  alias Squeeze.{Accounts, Guardian}

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "You have been logged out!")
    |> redirect(to: "/")
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    user_params = get_user!(provider, client)
    user = conn.assigns.current_user
    case Accounts.get_or_update_user_by_credential(user, user_params) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
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

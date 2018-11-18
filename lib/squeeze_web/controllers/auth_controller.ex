defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Guardian.Plug
  alias Strava.Auth

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def delete(conn, _params) do
    conn
    |> Plug.sign_out()
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
        |> Plug.sign_in(user)
        |> redirect(to: dashboard_path(conn, :index))
      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:info, "Didn't Work")
        |> redirect(to: "/")
    end
  end

  defp authorize_url!("strava") do
    Auth.authorize_url!(scope: "read,activity:read_all")
  end

  defp authorize_url!(_) do
    raise "No matching provider available"
  end

  defp get_token!("strava", code) do
    Auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_token!(_, _) do
    raise "No matching provider available"
  end

  defp get_user!("strava", client) do
    %{access_token: access_token, refresh_token: refresh_token} = client.token
    user = Auth.get_athlete!(client)
    credential = %{provider: "strava", uid: user.id, access_token: access_token, refresh_token: refresh_token}
    user
    |> Map.from_struct
    |> Map.merge(%{first_name: user.firstname, last_name: user.lastname, avatar: user.profile})
    |> Map.merge(%{credential: credential})
  end
end

defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller

  alias OAuth2.Client
  alias Squeeze.Accounts
  alias Squeeze.Guardian.Plug
  alias Squeeze.OAuth2.{Facebook, Google}

  @strava_auth Application.get_env(:squeeze, :strava_auth)

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
    @strava_auth.authorize_url!(scope: "read,activity:read_all")
  end

  defp authorize_url!("google") do
    Google.authorize_url!(scope: "email")
  end

  defp authorize_url!("facebook") do
    Facebook.authorize_url!(scope: "email,public_profile")
  end

  defp get_token!("strava", code) do
    @strava_auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_token!("google", code), do: Google.get_token!(code: code)
  defp get_token!("facebook", code), do: Facebook.get_token!(code: code)

  defp get_user!("strava", client) do
    %{access_token: access_token, refresh_token: refresh_token} = client.token
    user = @strava_auth.get_athlete!(client)
    credential = %{provider: "strava", uid: "#{user.id}", access_token: access_token, refresh_token: refresh_token}
    user
    |> Map.from_struct
    |> Map.merge(%{first_name: user.firstname, last_name: user.lastname, avatar: user.profile})
    |> Map.merge(%{credential: credential})
  end

  defp get_user!("google", client) do
    %{body: user} =
      Client.get!(client, "https://www.googleapis.com/userinfo/v2/me")
    %{
      avatar: user["picture"],
      email: user["email"],
      first_name: user["given_name"],
      last_name: user["family_name"],
      credential: %{
        access_token: client.token.access_token,
        provider: "google",
        uid: user["id"]
      }
    }
  end

  defp get_user!("facebook", client) do
    %{body: user} =
      Client.get!(client, "/me?fields=email,id,first_name,last_name")
    uid = user["id"]
    %{
      avatar: "https://graph.facebook.com/#{uid}/picture?type=square",
      email: user["email"],
      first_name: user["first_name"],
      last_name: user["last_name"],
      credential: %{
        access_token: client.token.access_token,
        provider: "facebook",
        uid: uid
      }
    }
  end
end

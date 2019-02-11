defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller

  alias OAuth2.Client
  alias Squeeze.Accounts
  alias Squeeze.Billing
  alias Squeeze.Guardian.Plug
  alias Squeeze.OAuth2.{Facebook, Fitbit, Google}

  @strava_auth Application.get_env(:squeeze, :strava_auth)

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    user_params = get_user!(provider, client)
    credential = user_params[:credential]
    current_user = conn.assigns.current_user
    cond do
      user = Accounts.get_user_by_credential(credential) ->
        sign_in_and_redirect(conn, user)
      user = Accounts.get_user_by_email(user_params[:email]) ->
        Accounts.create_credential(user, credential)
        sign_in_and_redirect(conn, user)
      true ->
        case Accounts.update_user(current_user, user_params) do
          {:ok, user} ->
            Accounts.create_credential(user, credential)
            Billing.start_free_trial(user)
            sign_in_and_redirect(conn, user)
          {:error, _} ->
            conn
            |> put_flash(:info, "Authentication Failed")
            |> redirect(to: "/")
        end
    end
  end

  defp sign_in_and_redirect(conn, user) do
    conn
    |> Plug.sign_in(user)
    |> redirect(to: dashboard_path(conn, :index))
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

  defp authorize_url!("fitbit") do
    Fitbit.authorize_url!(scope: "activity profile")
  end

  defp get_token!("strava", code) do
    @strava_auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_token!("google", code), do: Google.get_token!(code: code)
  defp get_token!("facebook", code), do: Facebook.get_token!(code: code)
  defp get_token!("fitbit", code), do: Fitbit.get_token!(code: code)

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

  defp get_user!("fitbit", client) do
    %{body: body} = Client.get!(client, "/1/user/-/profile.json")
    user = body["user"]
    token = client.token
    %{
      first_name: user["firstName"],
      last_name: user["lastName"],
      credential: %{
        access_token: token.access_token,
        refresh_token: token.refresh_token,
        provider: "fitbit",
        uid: token.other_params["user_id"]
      }
    }
  end
end

defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Guardian.Plug
  alias Squeeze.OAuth2.{Fitbit, Google}

  @strava_auth Application.get_env(:squeeze, :strava_auth)

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    user_params = get_user!(provider, client)
    email = user_params[:email]
    credential = user_params[:credential]
    current_user = conn.assigns.current_user
    cond do
      user = Accounts.get_user_by_credential(credential) ->
        sign_in_and_redirect(conn, user)
      user = email && Accounts.get_user_by_email(email) ->
        Accounts.create_credential(user, credential)
        redirect_current_user(conn, provider)
      true ->
        case Accounts.update_user(current_user, user_params) do
          {:ok, user} ->
            Accounts.create_credential(user, credential)
            redirect_current_user(conn, provider)
          {:error, _} ->
            conn
            |> put_flash(:error, "Authentication Failed")
            |> redirect(to: "/")
        end
    end
  end

  defp redirect_current_user(conn, provider) do
    conn
    |> put_flash(:info, "Connected to #{provider}")
    |> redirect(to: dashboard_path(conn, :index))
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

  defp authorize_url!("fitbit") do
    Fitbit.authorize_url!(scope: "activity profile")
  end

  defp get_token!("strava", code) do
    @strava_auth.get_token!(code: code, grant_type: "authorization_code")
  end

  defp get_token!("google", code), do: Google.get_token!(code: code)
  defp get_token!("fitbit", code), do: Fitbit.get_token!(code: code)

  defp get_user!("strava", client) do
    %{access_token: access_token, refresh_token: refresh_token} = client.token
    user = @strava_auth.get_athlete!(client)
    credential = %{provider: "strava", uid: "#{user.id}", access_token: access_token, refresh_token: refresh_token}
    %{credential: credential}
  end

  defp get_user!("google", client), do: Google.get_user!(client)
  defp get_user!("fitbit", client), do: Fitbit.get_user!(client)
end

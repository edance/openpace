defmodule FitbitWeb.AuthController do
  use FitbitWeb, :controller

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    user = get_user!(provider, client)

    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, client.token.access_token)
    |> redirect(to: "/")
  end

  defp authorize_url!("fitbit") do
    scope = "activity heartrate location nutrition profile settings sleep social weight"
    FitbitAuth.authorize_url!(scope: scope)
  end

  defp authorize_url!(_) do
    raise "No matching provider available"
  end

  defp get_token!("fitbit", code) do
    FitbitAuth.get_token!(code: code)
  end

  defp get_token!(_, _) do
    raise "No matching provider available"
  end

  defp get_user!("fitbit", client) do
    %{body: body} = OAuth2.Client.get!(client, "/1/user/-/profile.json")
    %{
      name: body["user"]["displayName"],
      full_name: body["user"]["fullName"],
      display_name: body["user"]["displayName"],
      nickname: body["user"]["nickname"],
      gender: body["user"]["gender"],
      about_me: body["user"]["aboutMe"],
      city: body["user"]["city"],
      state: body["user"]["state"],
      country: body["user"]["country"],
      timezone: body["user"]["timezone"]
    }
  end
end

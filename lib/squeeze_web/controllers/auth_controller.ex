defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Guardian.Plug
  alias Squeeze.OAuth2.{Google}

  def request(conn, %{"provider" => provider}) do
    redirect(conn, external: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    user_params = get_user!(provider, client)
    credential = user_params[:credential]
    cond do
      user = Accounts.get_user_by_credential(credential) ->
        sign_in_and_redirect(conn, user)
      user = Accounts.get_user_by_email(user_params[:email]) ->
        sign_in_and_redirect(conn, user)
      true ->
        create_user(conn, user_params)
    end
  end

  defp create_user(conn, user_params) do
    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, _} <- Accounts.create_credential(user, user_params[:credential]) do
      redirect_current_user(conn)
    else
      _err ->
        conn
        |> put_flash(:error, "Could not be authenticated")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  defp redirect_current_user(conn) do
    conn
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  defp sign_in_and_redirect(conn, user) do
    conn
    |> Plug.sign_in(user)
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  defp authorize_url!("google"), do: Google.authorize_url!(scope: "profile openid email")

  defp get_token!("google", code), do: Google.get_token!(code: code)

  defp get_user!("google", client), do: Google.get_user!(client)
end

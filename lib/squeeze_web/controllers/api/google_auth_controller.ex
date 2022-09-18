defmodule SqueezeWeb.Api.GoogleAuthController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Guardian
  alias Squeeze.OAuth2.Google

  action_fallback SqueezeWeb.Api.FallbackController

  def auth(conn, %{"access_token" => token}) do
    client = Google.client(token: token)
    user_params = Google.get_user!(client)
    credential = user_params[:credential]

    cond do
      user = Accounts.get_user_by_credential(credential) ->
        render_token(conn, user)
      user = Accounts.get_user_by_email(user_params[:email]) ->
        render_token(conn, user)
      true ->
        create_user(conn, user_params)
    end
  end

  defp render_token(conn, user) do
    with {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("auth.json", %{token: token})
    end
  end

  defp create_user(conn, user_params) do
    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, _} <- Accounts.create_credential(user, user_params[:credential]) do
      render_token(conn, user)
    end
  end
end

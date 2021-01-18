defmodule SqueezeWeb.Api.AppleAuthController do
  use SqueezeWeb, :controller

  # alias Squeeze.Accounts
  # alias Squeeze.Guardian
  # alias Squeeze.OAuth2.Google

  action_fallback SqueezeWeb.Api.FallbackController

  @config [
    client_id: System.get_env("APPLE_CLIENT_ID"),
    team_id: System.get_env("APPLE_TEAM_ID"),
    private_key_id: System.get_env("APPLE_PRIVATE_KEY"),
    private_key: System.get_env("APPLE_PRIVATE_KEY"),
    redirect_uri: nil
  ]

  def auth(conn, %{"authentication_code" => code}) do
    with {:ok, %{user: _user, token: token}} <- get_user(code) do
      conn
      |> put_status(:created)
      |> render("auth.json", %{token: token})
    end


    # client = Google.client(token: token)
    # user_params = Google.get_user!(client)
    # credential = user_params[:credential]

    # cond do
    #   user = Accounts.get_user_by_credential(credential) ->
    #     render_token(conn, user)
    #   user = Accounts.get_user_by_email(user_params[:email]) ->
    #     render_token(conn, user)
    #   true ->
    #     create_user(conn, user_params)
    # end
  end

  # defp render_token(conn, user) do
  #   with {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
  #     conn
  #     |> put_status(:created)
  #     |> render("auth.json", %{token: token})
  #   end
  # end

  # defp create_user(conn, user_params) do
  #   with {:ok, user} <- Accounts.register_user(user_params),
  #        {:ok, _} <- Accounts.create_credential(user, user_params[:credential]) do
  #     render_token(conn, user)
  #   end
  # end

  defp get_user(code) do
    @config
    |> Assent.Config.put(:session_params, %{})
    |> Assent.Strategy.Apple.callback(%{"code" => code})
  end
end

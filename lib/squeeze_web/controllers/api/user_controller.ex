defmodule SqueezeWeb.Api.UserController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Guardian

  action_fallback SqueezeWeb.Api.FallbackController

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("user.json", %{user: user, token: token})
    end
  end

  def signin(conn, %{"email" => email, "password" => password}) do
    with {:ok, user, token} <- Guardian.authenticate(email, password) do
      conn
      |> put_status(:created)
      |> render("user.json", %{user: user, token: token})
    end
  end
end

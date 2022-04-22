defmodule SqueezeWeb.Api.UserController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Guardian
  alias Squeeze.Repo

  action_fallback SqueezeWeb.Api.FallbackController

  def show(conn, %{"slug" => slug}) do
    user = Accounts.get_user_by_slug!(slug)
    render(conn, "user.json", %{user: user})
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do

      user = Repo.preload(user, [:credentials, :user_prefs])

      conn
      |> put_status(:created)
      |> render("auth.json", %{user: user, token: token})
    end
  end

  def signin(conn, %{"email" => email, "password" => password}) do
    with {:ok, user, token} <- Guardian.authenticate(email, password) do
      user = Repo.preload(user, [:credentials, :user_prefs])

      conn
      |> put_status(:created)
      |> render("auth.json", %{user: user, token: token})
    end
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    with {:ok, _} <- Accounts.update_user(user, user_params) do
      send_resp(conn, :no_content, "")
    end
  end

  def me(conn, _) do
    user = Repo.preload(conn.assigns.current_user, [:credentials, :user_prefs])
    render(conn, "me.json", %{user: user})
  end
end

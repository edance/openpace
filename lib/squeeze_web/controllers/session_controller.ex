defmodule SqueezeWeb.SessionController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias SqueezeWeb.Plug.Auth

  def new(conn, _params) do
    render(conn, "new.html", page_title: "Sign into your account")
  end

  def create(conn, %{"session" => auth_params}) do
    user = Accounts.get_user_by_email(auth_params["email"])
    case check_password(user, auth_params["password"]) do
      {:ok, user} ->
        conn
        |> Auth.sign_in(user)
        |> put_flash(:info, "Signed in successfully.")
        |> redirect(to: Routes.overview_path(conn, :index))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> put_status(:unprocessable_entity)
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.sign_out()
    |> put_flash(:info, "You have been logged out!")
    |> redirect(to: "/")
  end

  defp check_password(nil, _), do: {:error, "Invalid email"}
  defp check_password(%User{encrypted_password: nil}, _) do
    {:error, "Invalid password"}
  end
  defp check_password(%User{} = user, password) do
    Argon2.check_pass(user, password)
  end
end

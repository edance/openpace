defmodule SqueezeWeb.SessionController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Guardian.Plug

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => auth_params}) do
    user = Accounts.get_user_by_email(auth_params["email"])
    case check_password(user, auth_params["password"]) do
      {:ok, user} ->
        conn
        |> Plug.sign_in(user)
        |> put_flash(:info, "Signed in successfully.")
        |> redirect(to: Routes.dashboard_path(conn, :index))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Plug.sign_out()
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

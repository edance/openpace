defmodule SqueezeWeb.UserController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.{Email, Mailer}
  alias Squeeze.Guardian.Plug

  def new(conn, %{}) do
    case conn.assigns[:current_user] do
      nil ->
        changeset = Accounts.change_user(%User{})
        render(conn, "new.html", changeset: changeset)
      _ -> redirect(conn, to: Routes.dashboard_path(conn, :index))
    end
  end

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> Plug.sign_in(user)
        |> send_welcome_email(user)
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.dashboard_path(conn, :index))
      {:error, changeset} ->
        render_error(conn, changeset)
    end
  end

  defp render_error(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render("new.html", changeset: changeset)
  end

  defp send_welcome_email(conn, user) do
    user
    |> Email.welcome_email()
    |> Mailer.deliver_later()

    conn
  end
end

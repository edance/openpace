defmodule SqueezeWeb.UserController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.{Email, Mailer}
  alias SqueezeWeb.Plug.Auth

  @honeypot_field "website"
  plug :validate_honeypot when action in [:register]

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
        |> Auth.sign_in(user)
        |> send_welcome_email(user)
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.dashboard_path(conn, :index))
      {:error, changeset} ->
        render_error(conn, changeset)
    end
  end

  defp validate_honeypot(conn, _) do
    if conn.params["user"][@honeypot_field] == "" do
      conn
    else
      changeset = Accounts.change_user(%User{})
      conn
      |> put_flash(:error, "Sorry we can't process your request. Error code: 005")
      |> render_error(changeset)
      |> halt()
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

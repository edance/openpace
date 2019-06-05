defmodule SqueezeWeb.ForgotPasswordController do
  use SqueezeWeb, :controller

  alias Squeeze.{Accounts, Email, Mailer, PasswordLinkGenerator}

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def request(conn, params) do
    case Accounts.get_user_by_email(params["email"]) do
      nil ->
        conn
        |> put_flash(:error, "Email not found in our systems")
        |> render("show.html")
      user ->
        user
        |> Email.reset_password_email(PasswordLinkGenerator.create_link(user))
        |> Mailer.deliver_now()
        conn
        |> put_flash(:info, "Link sent to email")
        |> redirect(to: Routes.home_path(conn, :index))
    end
  end
end

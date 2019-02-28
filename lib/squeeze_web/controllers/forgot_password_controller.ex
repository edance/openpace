defmodule SqueezeWeb.ForgotPasswordController do
  use SqueezeWeb, :controller

  alias Squeeze.{Accounts, Email, Mailer, PasswordLinkGenerator}

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def request(conn, params) do
    user = Accounts.get_user_by_email(params["email"])
    user
    |> Email.reset_password_email(PasswordLinkGenerator.create_link(user))
    |> Mailer.deliver_now()
    conn
    |> put_flash(:info, "Link sent to email")
    |> redirect(to: page_path(conn, :index))
  end
end

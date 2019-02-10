defmodule SqueezeWeb.ForgotPasswordController do
  use SqueezeWeb, :controller

  alias Squeeze.{Accounts, Crypto, Email, Mailer}

  @base_url System.get_env("HOST_URL")

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def request(conn, params) do
    user = Accounts.get_user_by_email(params["email"])
    user
    |> Email.reset_password_email(reset_password_link(user))
    |> Mailer.deliver_now()
    conn
    |> put_flash(:info, "Link sent to email")
    |> redirect(to: page_path(conn, :index))
  end

  defp reset_password_link(user) do
    current_time = to_string(:erlang.system_time(:seconds))
    reset_string = Base.url_encode64("#{current_time},#{user.id}")
    signature = Crypto.sign(reset_string)
    "#{@base_url}/reset-password?token=#{reset_string}&signature=#{signature}"
  end
end

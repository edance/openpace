defmodule FitbitWeb.AuthController do
  use FitbitWeb, :controller
  plug Ueberauth

  require Logger
  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    conn
    |> put_session(:access_token, auth.credentials.token)
    |> put_session(:current_user, auth.info)
    |> put_flash(:info, "Logged In")
    |> redirect(to: "/")
  end
end

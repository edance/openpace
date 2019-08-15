defmodule SqueezeWeb.HomeController do
  use SqueezeWeb, :controller

  def index(conn, _params) do
    user = conn.assigns.current_user
    if user.registered do
      conn
      |> redirect(to: Routes.dashboard_path(conn, :index))
      |> halt()
    else
      conn
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end

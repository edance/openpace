defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller

  def index(conn, _params) do
    case Squeeze.Guardian.Plug.authenticated?(conn) do
      false -> render(conn, "index.html")
      true -> redirect(conn, to: dashboard_path(conn, :index))
    end
  end
end

defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :user_id) do
      nil -> render(conn, "index.html")
      user_id -> redirect(conn, to: dashboard_path(conn, :index))
    end
  end
end

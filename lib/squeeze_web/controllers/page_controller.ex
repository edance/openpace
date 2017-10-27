defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
    |> render "index.html"
  end
end

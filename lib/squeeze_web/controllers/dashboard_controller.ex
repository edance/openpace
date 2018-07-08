defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: event_path(conn, :index))
  end
end

defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Sync

  def index(conn, _params) do
    Sync.load_activities(conn.assigns.current_user)
    conn
    |> redirect(to: activity_path(conn, :index))
  end
end

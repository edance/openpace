defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Strava.HistoryLoader

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    Task.start(fn -> HistoryLoader.load_recent(current_user) end)
    redirect(conn, to: overview_path(conn, :index))
  end
end

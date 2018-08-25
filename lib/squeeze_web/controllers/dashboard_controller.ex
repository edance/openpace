defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def index(conn, _params) do
    activities = Dashboard.list_activities(conn.assigns.current_user)
    render(conn, "index.html", activities: activities)
  end
end

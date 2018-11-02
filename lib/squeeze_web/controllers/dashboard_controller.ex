defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def index(conn, _params) do
    user = conn.assigns.current_user
    events = Dashboard.list_past_events(user)
    activities = Dashboard.list_activities(conn.assigns.current_user)
    render(conn, "index.html", activities: activities, events: events)
  end

  def example(conn, _) do
    render(conn, "example.html")
  end
end

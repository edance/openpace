defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def index(conn, _params) do
    user = conn.assigns.current_user
    Exq.enqueue(Exq, "default", Squeeze.SyncWorker, [user.id])
    events = Dashboard.list_past_events(user)
    activities = Dashboard.list_activities(conn.assigns.current_user)
    render(conn, "index.html", activities: activities, events: events)
  end
end

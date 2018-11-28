defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Sync

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    Task.start(fn -> Sync.load_activities(current_user) end)
    Squeeze.Stats.distance_by_month(current_user)

    activities = Dashboard.list_activities(current_user)
    render(conn, "index.html",
      activities: activities,
      events: events(current_user)
    )
  end

  defp events(current_user) do
    today = Date.utc_today()
    range = Date.range(today, Date.add(today, 1))
    Dashboard.list_events(current_user, range)
  end
end

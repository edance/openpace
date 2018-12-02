defmodule SqueezeWeb.OverviewController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Stats

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    activities = Dashboard.list_activities(current_user)
    render(conn, "index.html",
      activities: activities,
      events: events(current_user),
      distance_by_week: Stats.distance_by_week(current_user),
      distance_by_day: Stats.distance_by_day(current_user)
    )
  end

  defp events(current_user) do
    today = Date.utc_today()
    range = Date.range(today, Date.add(today, 1))
    Dashboard.list_events(current_user, range)
  end
end

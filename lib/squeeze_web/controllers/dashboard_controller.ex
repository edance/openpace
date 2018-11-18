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

    events = Dashboard.list_past_events(current_user)
    activities = Dashboard.list_activities(current_user)
    render(conn, "index.html", activities: activities, events: events)
  end

  def example(conn, _params, _current_user) do
    render(conn, "example.html")
  end
end

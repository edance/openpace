defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, current_user) do
    activities = Dashboard.recent_activities(current_user)
    render(conn, "index.html", activities: activities)
  end

  def show(conn, %{"id" => id}, user) do
    activity = Dashboard.get_activity!(user, id)
    render(conn, "show.html",
      activity: activity,
      altitude: [],
      coordinates: [],
      distance: [],
      heartrate: [],
      splits: [],
      velocity: []
    )
  end
end

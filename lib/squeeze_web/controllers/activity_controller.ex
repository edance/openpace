defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def index(conn, _params) do
    activities = Dashboard.list_activities(conn.assigns.current_user)
    render(conn, "index.html", activities: activities)
  end

  def show(conn, %{"id" => id}) do
    activity = Dashboard.get_activity!(id)
    render(conn, "show.html", activity: activity)
  end
end

defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def index(conn, _params) do
    user = conn.assigns.current_user
    conn
    |> assign(:goal, Dashboard.get_current_goal(user))
    |> assign(:activities, Dashboard.get_todays_activities(user))
    |> render("index.html")
  end
end

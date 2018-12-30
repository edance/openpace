defmodule SqueezeWeb.OverviewController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Stats

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    activities = Dashboard.recent_activities(current_user)
    render(conn, "index.html",
      activities: activities,
      week_dataset: Stats.dataset_for_week_chart(current_user),
      year_dataset: Stats.dataset_for_year_chart(current_user)
    )
  end
end

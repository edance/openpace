defmodule SqueezeWeb.OverviewController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Stats

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, user) do
    render(conn, "index.html",
      activities: Dashboard.recent_activities(user),
      todays_activities: Dashboard.todays_activities(user),
      week_dataset: Stats.dataset_for_week_chart(user),
      year_dataset: Stats.dataset_for_year_chart(user)
    )
  end
end

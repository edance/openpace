defmodule SqueezeWeb.OverviewController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Challenges
  alias Squeeze.Stats

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, user) do
    activities = Dashboard.recent_activities(user)
    run_activities = run_activities(activities)
    challenges = Challenges.list_current_challenges(user)

    render(conn, "index.html",
      activity_summaries: Dashboard.list_activity_summaries(),
      activities: activities,
      challenges: challenges,
      run_activities: run_activities,
      run_dates: run_dates(run_activities),
      todays_activities: Dashboard.todays_activities(user),
      year_dataset: Stats.dataset_for_year_chart(user)
    )
  end

  defp run_activities(activities) do
    activities
    |> Enum.filter(&(String.contains?(&1.type, "Run")))
  end

  defp run_dates(activities) do
    activities
    |> Enum.map(&(&1.planned_date))
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end
end

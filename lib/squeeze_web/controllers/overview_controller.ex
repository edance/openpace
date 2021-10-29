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
    summaries = Dashboard.list_activity_summaries()
    weekly_sums = weekly_sums(summaries)
    year_dataset = Stats.dataset_for_year_chart(user)

    render(conn, "index.html",
      activity_summaries: summaries,
      activities: activities,
      challenges: challenges,
      run_activities: run_activities,
      run_dates: run_dates(run_activities),
      todays_activities: Dashboard.todays_activities(user),
      year_dataset: year_dataset
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

  defp weekly_sums(summaries) do
    summaries
    |> Enum.reduce(%{}, fn(x, acc) ->
      date = Timex.beginning_of_week(x.start_at_local) |> Timex.to_date()
      value = Map.get(acc, date, %{distance: 0, duration: 0})
      distance = value.distance + x.distance
      duration = value.duration + x.duration
      Map.put(acc, date, %{distance: distance, duration: duration})
    end)
  end
end

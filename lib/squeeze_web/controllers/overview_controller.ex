defmodule SqueezeWeb.OverviewController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Challenges

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, user) do
    activities = Dashboard.recent_activities(user)
    challenges = Challenges.list_current_challenges(user)
    summaries = Dashboard.list_activity_summaries(user)
    activity_map = activity_map(summaries)
    stats = Squeeze.Stats.ytd_run_summary(user)

    render(conn, "index.html",
      activity_map: activity_map,
      activity_summaries: summaries,
      activities: activities,
      challenges: challenges,
      run_activities: run_activities(summaries),
      run_dates: run_dates(summaries),
      todays_activities: Dashboard.todays_activities(user),
      ytd_run_stats: stats
    )
  end

  defp activity_map(summaries) do
    summaries
    |> Enum.reduce(%{}, fn(x, acc) ->
      date = x.start_at_local |> Timex.to_date()
      list = Map.get(acc, date, [])
      Map.put(acc, date, [x | list])
    end)
  end

  defp run_activities(summaries) do
    summaries
    |> Enum.filter(&(String.contains?(&1.type, "Run")))
  end

  defp run_dates(summaries) do
    summaries
    |> Enum.filter(&(String.contains?(&1.type, "Run")))
    |> Enum.map(&(Timex.to_date(&1.start_at_local)))
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end
end

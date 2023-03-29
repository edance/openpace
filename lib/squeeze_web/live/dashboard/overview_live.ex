defmodule SqueezeWeb.Dashboard.OverviewLive do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Accounts.User
  alias Squeeze.Challenges
  alias Squeeze.Activities
  alias Squeeze.Races
  alias Squeeze.Stats
  alias Squeeze.Strava.HistoryLoader
  alias Squeeze.TimeHelper

  import Squeeze.Distances, only: [distance_name: 2]

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    summaries = Activities.list_activity_summaries(user)
    activity_map = activity_map(summaries)
    race_goals = Races.list_upcoming_race_goals(user)

    socket =
      assign(socket,
        page_title: "Dashboard",
        current_user: user,
        activity_map: activity_map,
        activity_summaries: summaries,
        challenges: Challenges.list_current_challenges(user),
        current_streak: Stats.current_activity_streak(user),
        race_goal: List.first(race_goals),
        race_goals: race_goals,
        ytd_run_stats: Stats.ytd_run_summary(user)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("load-week", params, socket) do
    {:noreply,
     push_patch(socket,
       to: Routes.overview_path(socket, :index, date: params["date"]),
       replace: true
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    user = socket.assigns.current_user
    date = parse_date(user, params["date"])
    dates = Date.range(Timex.beginning_of_week(date), Timex.end_of_week(date))
    activities = Activities.list_activities(user, dates)

    if sync_history?(params, socket) do
      credential = Enum.find(user.credentials, &(&1.provider == "strava"))
      load_strava_history(user, credential)
    end

    socket =
      assign(socket,
        activities: activities,
        syncing: sync_history?(params, socket),
        date: date
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info(:sync_finished, socket) do
    socket = assign(socket, syncing: false)
    {:noreply, socket}
  end

  defp sync_history?(params, socket) do
    params["sync"] && strava_integration?(socket.assigns)
  end

  defp strava_integration?(%{current_user: user}) do
    Enum.any?(user.credentials, &(&1.provider == "strava"))
  end

  defp personal_records(%{current_user: user}) do
    user.user_prefs.personal_records
    |> Enum.reject(&(is_nil(&1.duration) || &1.duration == 0))
    |> Enum.sort_by(& &1.distance)
  end

  defp activity_map(summaries) do
    summaries
    |> Enum.reduce(%{}, fn x, acc ->
      date = x.start_at_local |> Timex.to_date()
      list = Map.get(acc, date, [])
      Map.put(acc, date, [x | list])
    end)
  end

  defp parse_date(%User{} = user, nil), do: TimeHelper.today(user)

  defp parse_date(%User{} = user, date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> parse_date(user, nil)
    end
  end

  defp load_strava_history(user, credential) do
    view = self()

    Task.start_link(fn ->
      HistoryLoader.load_recent(user, credential)
      send(view, :sync_finished)
    end)
  end
end

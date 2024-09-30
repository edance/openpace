defmodule SqueezeWeb.RaceLive.Show do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Activities
  alias Squeeze.Distances
  alias Squeeze.RacePredictor
  alias Squeeze.Races
  alias Squeeze.Races.RaceGoal
  alias Squeeze.Strava.ActivityLoader

  embed_templates "components/*"

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = socket.assigns.current_user
    race_goal = Races.get_race_goal!(slug)
    activity = race_goal.activity
    vo2_max = vo2_max(race_goal)

    if connected?(socket) && activity && !activity.trackpoint_set do
      send(self(), :fetch_detailed_info)
    end

    socket =
      assign(socket,
        block_range: block_range(user, race_goal),
        past_activities: past_activities(user, race_goal),
        page_title: race_goal.race_name,
        race_goal: race_goal,
        activity: activity,
        trackpoints: trackpoints(activity),
        paces: race_goal.training_paces,
        predictions: predictions(vo2_max),
        vo2_max: vo2_max,
        current_user: user
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket =
      socket
      |> push_activity_events()

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Races.delete_race_goal(socket.assigns.race_goal)

    socket =
      socket
      |> redirect(to: Routes.race_path(socket, :index))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:fetch_detailed_info, socket) do
    user = socket.assigns.current_user
    existing_activity = socket.assigns.activity
    credential = Enum.find(user.credentials, &(&1.provider == "strava"))

    if credential && existing_activity.external_id do
      ActivityLoader.update_or_create_activity(credential, existing_activity.external_id)
      activity = Activities.get_detailed_activity_by_slug!(user, existing_activity.slug)

      socket =
        socket
        |> assign(activity: activity, trackpoints: trackpoints(activity), current_user: user)
        |> push_activity_events()

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def block_range(_user, %RaceGoal{} = race_goal) do
    race_date = race_goal.race_date

    # 18 weeks before minus 1 day
    start_date = Timex.shift(race_date, days: 18 * -7 + 1)

    case Date.day_of_week(start_date) do
      1 -> Date.range(start_date, race_date)
      x -> Date.range(Date.add(start_date, -(x - 1)), race_date)
    end
  end

  def past_activities(user, %RaceGoal{} = race_goal) do
    range = block_range(user, race_goal)
    Activities.list_activities(user, range)
  end

  def distance_name(distance, current_user) do
    Distances.distance_name(distance, imperial: current_user.user_prefs.imperial)
  end

  defp trackpoints(nil), do: []
  defp trackpoints(%{trackpoint_set: nil}), do: []
  defp trackpoints(%{trackpoint_set: set}), do: set.trackpoints

  defp push_activity_events(socket) do
    if socket.assigns.activity do
      socket
      |> push_trackpoints()
      |> push_laps()
    else
      socket
    end
  end

  defp push_trackpoints(socket) do
    push_event(socket, "trackpoints", %{trackpoints: socket.assigns.trackpoints})
  end

  defp push_laps(socket) do
    push_event(socket, "laps", %{laps: socket.assigns.activity.laps})
  end

  defp vo2_max(%{distance: distance, duration: duration, activity: activity}) do
    cond do
      activity && activity.distance > 0 && activity.duration > 0 ->
        RacePredictor.estimated_vo2max(activity.distance, activity.duration)

      distance > 0 && duration > 0 ->
        RacePredictor.estimated_vo2max(distance, duration)

      true ->
        nil
    end
  end

  defp show_map?(%{activity: activity}) do
    activity && activity.polyline
  end

  defp predictions(nil), do: %{}

  defp predictions(vo2_max) do
    RacePredictor.predict_all_race_times(vo2_max)
  end

  def bubble_size(distance) do
    # max bubble size is 50
    # min bubble size is 10
    # 5k is 10
    # 40k is 50
    # return number
    min = 50
    max = 100

    cond do
      is_nil(distance) -> min
      distance < 5_000 -> min
      distance > 40_000 -> max
      true -> (distance - 5_000) / 35_000 * (max - min) + min
    end
  end

  defp tab_class(active) do
    if active do
      "bg-indigo-100 text-indigo-700 rounded-md px-3 py-2 text-sm font-medium hover:text-gray-700"
    else
      "rounded-md px-3 py-2 text-sm font-medium text-gray-500 hover:text-gray-700"
    end
  end
end

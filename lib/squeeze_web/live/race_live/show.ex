defmodule SqueezeWeb.RaceLive.Show do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Number.Delimit
  alias Squeeze.Activities
  alias Squeeze.Distances
  alias Squeeze.RacePredictor
  alias Squeeze.Races
  alias Squeeze.Races.RaceGoal
  alias Squeeze.Strava.ActivityLoader
  alias Squeeze.TimeHelper

  embed_templates "components/*"

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = socket.assigns.current_user
    race_goal = Races.get_race_goal!(slug)
    activity = race_goal.activity
    vo2_max = vo2_max(race_goal)
    range = block_range(user, race_goal)
    trackpoint_sections = Activities.list_trackpoint_sections(user, range)

    if connected?(socket) && activity && !activity.trackpoint_set do
      send(self(), :fetch_detailed_info)
    end

    socket =
      assign(socket,
        block_range: range,
        past_activities: past_activities(user, race_goal),
        page_title: race_goal.race_name,
        race_goal: race_goal,
        activity: activity,
        trackpoints: trackpoints(activity),
        paces: race_goal.training_paces,
        predictions: predictions(vo2_max),
        vo2_max: vo2_max,
        current_user: user,
        trackpoint_sections: trackpoint_sections
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
  def handle_info({SqueezeWeb.RaceLive.RaceGoalForm, {:saved, race_goal}}, socket) do
    {:noreply, socket |> assign(:race_goal, race_goal)}
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

  defp elevation(%{activity: activity, current_user: user}) do
    imperial = user.user_prefs.imperial

    value =
      activity.elevation_gain
      |> Distances.to_feet(imperial: imperial)
      |> Delimit.number_to_delimited(precision: 0)

    if imperial do
      "#{value} ft"
    else
      "#{value} m"
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

  defp weeks(%{block_range: dates}) do
    dates
    |> Enum.with_index()
    |> Enum.group_by(fn {_, idx} -> div(idx, 7) + 1 end, fn {v, _} -> v end)
  end

  defp weekly_distance(activities, dates) do
    dates
    |> Enum.map(&distance_on_date(activities, &1))
    |> Enum.sum()
  end

  defp activities_on_date(activities, date) do
    activities
    |> Enum.filter(&(&1.activity_type == :run && Timex.to_date(&1.start_at_local) == date))
  end

  defp distance_on_date(activities, date) do
    activities
    |> activities_on_date(date)
    |> Enum.map(& &1.distance)
    |> Enum.sum()
  end

  defp show_map?(%{activity: activity}) do
    activity && activity.polyline
  end

  defp predictions(nil), do: %{}

  defp predictions(vo2_max) do
    RacePredictor.predict_all_race_times(vo2_max)
  end

  def date_bubble(assigns) do
    assigns =
      assigns
      |> assign(:activities, activities_on_date(assigns.past_activities, assigns.date))
      |> assign(:distance, distance_on_date(assigns.past_activities, assigns.date))
      |> assign_new(:past, fn ->
        Timex.before?(assigns.date, TimeHelper.today(assigns.current_user))
      end)

    ~H"""
    <div class="text-center w-full relative">
      <.bubble distance={@distance} activities={@activities} />

      <div :if={@distance > 0} class="text-xs text-gray-700 mt-1">
        <%= format_distance(@distance, @current_user.user_prefs) %>
      </div>

      <div
        :if={@distance <= 0 && @date == TimeHelper.today(@current_user)}
        class="text-xs text-red-700 mt-1"
      >
        <%= gettext("Today") %>
      </div>

      <div :if={@distance <= 0 && @past} class="text-xs text-gray-700 mt-1">
        Rest
      </div>
    </div>
    """
  end

  def bubble(assigns) do
    assigns =
      assigns
      |> assign(:size, bubble_size(assigns.distance))
      |> assign(:color, bubble_color(assigns.activities))

    ~H"""
    <div
      class={["rounded-full mx-auto bg-opacity-50", @color]}
      style={"width: #{@size}px; height: #{@size}px;"}
    >
    </div>
    """
  end

  def bubble_color(activities) do
    cond do
      Enum.empty?(activities) -> "bg-gray-500"
      Enum.any?(activities, &(&1.workout_type == :race)) -> "bg-red-500"
      Enum.any?(activities, &(&1.workout_type == :long_run)) -> "bg-green-500"
      Enum.any?(activities, &(&1.workout_type == :workout)) -> "bg-yellow-500"
      true -> "bg-blue-500"
    end
  end

  def bubble_size(distance) do
    # max bubble size is 50
    # min bubble size is 10
    # 5k is 10
    # 40k is 50
    # return number
    min = 10
    max = 50

    cond do
      is_nil(distance) -> min
      distance < 5_000 -> min
      distance > 40_000 -> max
      true -> (distance - 5_000) / 35_000 * (max - min) + min
    end
  end
end

defmodule SqueezeWeb.ActivityLive.Show do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Number.Delimit
  alias Squeeze.Dashboard
  alias Squeeze.Distances
  alias Squeeze.Strava.ActivityLoader

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = socket.assigns.current_user
    activity = Dashboard.get_detailed_activity_by_slug!(user, slug)

    if connected?(socket) && !activity.trackpoint_set do
      send(self(), :fetch_detailed_info)
    end

    socket =
      socket
      |> assign(page_title: activity.name)
      |> assign(activity: activity, trackpoints: trackpoints(activity), current_user: user)

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
  def handle_info(:fetch_detailed_info, socket) do
    user = socket.assigns.current_user
    existing_activity = socket.assigns.activity
    credential = Enum.find(user.credentials, &(&1.provider == "strava"))

    if credential && existing_activity.external_id do
      ActivityLoader.update_or_create_activity(credential, existing_activity.external_id)
      activity = Dashboard.get_detailed_activity_by_slug!(user, existing_activity.slug)

      socket =
        socket
        |> assign(activity: activity, trackpoints: trackpoints(activity), current_user: user)
        |> push_activity_events()

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp push_activity_events(socket) do
    socket
    |> push_trackpoints()
    |> push_laps()
  end

  defp push_trackpoints(socket) do
    push_event(socket, "trackpoints", %{trackpoints: socket.assigns.trackpoints})
  end

  defp push_laps(socket) do
    push_event(socket, "laps", %{laps: socket.assigns.activity.laps})
  end

  defp date(%{activity: %{start_at: nil, planned_date: date}}) do
    Timex.format!(date, "%b %-d, %Y ", :strftime)
  end

  defp date(%{activity: activity, current_user: user}) do
    timezone = user.user_prefs.timezone

    activity.start_at
    |> Timex.to_datetime(timezone)
    |> Timex.format!("%b %-d, %Y %-I:%M %p ", :strftime)
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

  defp show_pace?(%{activity: activity}) do
    activity.activity_type == :run
  end

  defp trackpoints(%{trackpoint_set: nil}), do: []
  defp trackpoints(%{trackpoint_set: set}), do: set.trackpoints

  defp show_map?(%{activity: activity} = assigns) do
    activity.polyline || coordinates?(assigns)
  end

  defp coordinates?(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.take(5)
    |> Enum.map(& &1.coordinates)
    |> Enum.any?(&(!is_nil(&1)))
  end
end

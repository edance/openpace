defmodule SqueezeWeb.Activities.ShowLive do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Number.Delimit
  alias Squeeze.Dashboard
  alias Squeeze.Distances
  alias Squeeze.Strava.ActivityLoader

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user
    activity = Dashboard.get_detailed_activity!(user, id)

    if connected?(socket) && !activity.trackpoint_set do
      send(self(), :fetch_detailed_info)
    end

    socket = socket
    |> assign(page_title: activity.name)
    |> assign(activity: activity, trackpoints: trackpoints(activity), current_user: user)

    {:ok, socket}
  end

  @impl true
  def handle_info(:fetch_detailed_info, socket) do
    user = socket.assigns.current_user
    existing_activity = socket.assigns.activity
    credential = Enum.find(user.credentials, &(&1.provider == "strava"))

    if credential && existing_activity.external_id do
      ActivityLoader.update_or_create_activity(credential, existing_activity.external_id)
      activity = Dashboard.get_detailed_activity!(user, existing_activity.id)
      socket = socket
      |> assign(activity: activity, trackpoints: trackpoints(activity), current_user: user)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def name(%{activity: activity}) do
    activity.name || activity.type
  end

  def date(%{activity: %{start_at: nil, planned_date: date}}) do
    Timex.format!(date, "%b %-d, %Y ", :strftime)
  end
  def date(%{activity: activity, current_user: user}) do
    timezone = user.user_prefs.timezone
    activity.start_at
    |> Timex.to_datetime(timezone)
    |> Timex.format!("%b %-d, %Y %-I:%M %p ", :strftime)
  end

  def distance(%{activity: activity, current_user: user}) do
    Distances.to_float(activity.distance, user.user_prefs)
  end

  def distance?(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.take(5)
    |> Enum.map(&(&1.distance))
    |> Enum.any?(&(!is_nil(&1)))
  end

  def elevation(%{activity: activity, current_user: user}) do
    imperial = user.user_prefs.imperial
    value = activity.elevation_gain
    |> Distances.to_feet(imperial: imperial)
    |> Delimit.number_to_delimited(precision: 0)

    if imperial do
      "#{value} ft"
    else
      "#{value} m"
    end
  end

  def coordinates?(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.take(5)
    |> Enum.map(&(&1.coordinates))
    |> Enum.any?(&(!is_nil(&1)))
  end

  def show_splits?(%{trackpoints: trackpoints, activity: activity}) do
    !Enum.empty?(trackpoints) && activity.type == "Run"
  end

  def trackpoints?(%{trackpoints: trackpoints}) do
    !Enum.empty?(trackpoints)
  end

  defp trackpoints(%{trackpoint_set: nil}), do: []
  defp trackpoints(%{trackpoint_set: set}), do: set.trackpoints
end

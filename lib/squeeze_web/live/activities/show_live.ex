defmodule SqueezeWeb.Activities.ShowLive do
  use SqueezeWeb, :live_view

  alias Squeeze.Dashboard

  @impl true
  def mount(%{"id" => id}, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)
    activity = Dashboard.get_detailed_activity!(user, id)

    socket = socket
    |> assign(activity: activity, trackpoints: trackpoints(activity), current_user: user)

    {:ok, socket}
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

  def distance?(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.take(5)
    |> Enum.map(&(&1.distance))
    |> Enum.any?(&(!is_nil(&1)))
  end

  def coordinates?(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.take(5)
    |> Enum.map(&(&1.coordinates))
    |> Enum.any?(&(!is_nil(&1)))
  end

  def trackpoints?(%{trackpoints: trackpoints}) do
    !Enum.empty?(trackpoints)
  end

  defp trackpoints(%{trackpoint_set: nil}), do: []
  defp trackpoints(%{trackpoint_set: set}), do: set.trackpoints
end

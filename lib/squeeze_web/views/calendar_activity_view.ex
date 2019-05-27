defmodule SqueezeWeb.CalendarActivityView do
  use SqueezeWeb, :view

  alias Squeeze.TimeHelper

  def in_past?(%{current_user: user, date: date}) do
    TimeHelper.to_date(user, Timex.now)  >= date
  end

  def on_date?(user, date, activity) do
    activity.planned_date == date ||
      TimeHelper.to_date(user, activity.start_at)  == date
  end

  def activity_color(%{status: :pending}), do: "info"
  def activity_color(%{status: :complete}), do: "success"
  def activity_color(%{status: :incomplete}), do: "danger"
  def activity_color(%{status: :partial}), do: "warning"

  def activity_icon(activity) do
    cond do
      String.contains?(activity.type, "Run") ->
        "ic:baseline-directions-run"
      String.contains?(activity.type, "Ride") ->
        "ic:baseline-directions-bike"
      String.contains?(activity.type, "Swim") ->
        "map:swimming"
      true -> "map:gym"
    end
  end

  def distance_for_activities(activities, user_prefs) do
    distance = activities |> Enum.map(&(&1.distance)) |> Enum.sum()
    format_distance(distance, user_prefs)
  end

  def duration_for_activities(activities) do
    duration = activities |> Enum.map(&(&1.duration)) |> Enum.sum()
    format_duration(duration)
  end

  def pace_for_activities(activities, user_prefs) do
    distance = activities |> Enum.map(&(&1.distance)) |> Enum.sum()
    duration = activities |> Enum.map(&(&1.duration)) |> Enum.sum()
    format_pace(%{distance: distance, duration: duration}, user_prefs)
  end
end

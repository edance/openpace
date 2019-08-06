defmodule SqueezeWeb.CalendarActivityView do
  use SqueezeWeb, :view

  alias Squeeze.TimeHelper

  def on_date?(user, %NaiveDateTime{} = datetime, activity) do
    on_date?(user, NaiveDateTime.to_date(datetime), activity)
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

  def distance(%{distance: distance}, _) when distance == 0, do: nil
  def distance(%{distance: distance}, user) do
    format_distance(distance, user.user_prefs)
  end

  def pace(%{distance: distance}, _) when distance == 0, do: nil
  def pace(activity, user) do
    format_pace(activity, user.user_prefs)
  end

  def duration(%{duration: duration}) when duration == 0, do: nil
  def duration(%{duration: duration}) do
    format_duration(duration)
  end

  def description(%{activity: activity, current_user: user}) do
    [
      distance(activity, user),
      duration(activity),
      pace(activity, user),
      formatted_start_at(%{activity: activity, current_user: user})
    ]
    |> Enum.reject(&(is_nil(&1) || &1 <= 0))
    |> Enum.join(" · ")
  end

  def ordered_activities(%{activities: activities, current_user: user, date: date}) do
    activities
    |> Enum.filter(&(on_date?(user, date, &1)))
    |> Enum.sort_by(&(&1.start_at))
  end

  def formatted_start_at(%{activity: activity, current_user: user}) do
    timezone = user.user_prefs.timezone

    activity.start_at
    |> Timex.to_datetime(timezone)
    |> Timex.format!("%-I:%M %p ", :strftime)
  end
end

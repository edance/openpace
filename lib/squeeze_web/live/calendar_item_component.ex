defmodule SqueezeWeb.CalendarItemComponent do
  use SqueezeWeb, :live_component

  def activity_color(activity) do
    cond do
      String.contains?(activity.type, "Run") -> "blue"
      String.contains?(activity.type, "Ride") -> "purple"
      String.contains?(activity.type, "Swim") -> "pink"
      true -> "indigo"
    end
  end

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
  def distance(activity, user) do
    if activity.distance_amount && activity.distance_unit do
      "#{activity.distance_amount} #{activity.distance_unit}"
    else
      format_distance(activity.distance, user.user_prefs)
    end
  end

  def pace(%{distance: distance}, _) when distance == 0, do: nil
  def pace(%{duration: duration}, _) when duration == 0, do: nil
  def pace(activity, user) do
    format_pace(activity, user.user_prefs)
  end

  def duration(%{duration: duration}) when duration == 0, do: nil
  def duration(%{duration: duration}) do
    format_duration(duration)
  end

  def description(activity, user) do
    [
      distance(activity, user),
      duration(activity)
    ]
    |> Enum.reject(&(is_nil(&1) || &1 <= 0))
    |> Enum.join(" · ")
  end

  def ordered_activities(%{activities: activities}) do
    activities
    |> Enum.sort_by(&(&1.start_at))
  end

  def formatted_start_at(%{activity: %{start_at: nil}}), do: nil
  def formatted_start_at(%{activity: activity, current_user: user}) do
    timezone = user.user_prefs.timezone

    activity.start_at
    |> Timex.to_datetime(timezone)
    |> Timex.format!("%-I:%M %p ", :strftime)
  end
end

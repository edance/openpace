defmodule SqueezeWeb.Activities.CardsComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.Distances

  def duration(%{activity: activity}) do
    cond do
      activity.duration && activity.duration > 0 ->
        format_duration(activity.duration)
      activity.planned_duration && activity.planned_duration > 0 ->
        format_duration(activity.planned_duration)
      true ->
        "N/A"
    end
  end

  def distance(%{activity: activity, current_user: user}) do
    cond do
      activity.distance_amount && activity.distance_unit ->
        "#{activity.distance_amount} #{activity.distance_unit}"
      activity.distance && activity.distance > 0 ->
        format_distance(activity.distance, user.user_prefs)
      activity.planned_distance_amount && activity.planned_distance_unit ->
        "#{activity.planned_distance_amount} #{activity.planned_distance_unit}"
      true ->
        "N/A"
    end
  end

  def elevation(%{activity: %{elevation_gain: nil}}), do: "N/A"
  def elevation(%{activity: activity, current_user: user}) do
    imperial = user.user_prefs.imperial
    value = Distances.to_feet(activity.elevation_gain, imperial: imperial)
    if imperial do
      "#{value} ft"
    else
      "#{value} m"
    end
  end
end

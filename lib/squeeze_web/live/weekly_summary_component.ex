defmodule SqueezeWeb.WeeklySummaryComponent do
  use SqueezeWeb, :live_component

  alias Squeeze.Distances

  def completed_distance(%{activities: activities, current_user: user}) do
    activities
    |> Enum.map(&(&1.distance || 0))
    |> Enum.sum()
    |> Distances.to_float(imperial: user.user_prefs.imperial)
  end

  def distance_label(%{current_user: user}) do
    Distances.label(imperial: user.user_prefs.imperial)
  end
end

defmodule SqueezeWeb.ActivityChartView do
  use SqueezeWeb, :view

  alias Squeeze.{Distances, Velocity}

  def altitude(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> filter_by_field(:altitude)
    |> Enum.map(&(Distances.to_feet(&1, imperial: imperial)))
    |> smooth()
    |> Jason.encode!()
  end

  def cadence(%{trackpoints: trackpoints}) do
    trackpoints
    |> filter_by_field(:cadence)
    |> Enum.map(&(&1 * 2))
    |> smooth()
    |> Jason.encode!()
  end

  def distance(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> filter_by_field(:distance)
    |> Enum.map(&(Distances.to_float(&1, imperial: imperial)))
    |> smooth()
    |> Jason.encode!()
  end

  def heartrate(%{trackpoints: trackpoints}) do
    trackpoints
    |> filter_by_field(:heartrate)
    |> smooth()
    |> Jason.encode!()
  end

  def time(%{trackpoints: trackpoints}) do
    trackpoints
    |> filter_by_field(:time)
    |> smooth()
    |> Jason.encode!()
  end

  def velocity(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> filter_by_field(:velocity)
    |> Enum.map(&(Velocity.to_float(&1, imperial: imperial)))
    |> smooth()
    |> Jason.encode!()
  end

  def filter_by_field(trackpoints, field) do
    trackpoints
    |> Enum.filter(&(&1.moving))
    |> Enum.map(&(Map.get(&1, field)))
    |> Enum.reject(&is_nil/1)
  end

  defp smooth(points) do
    points
    |> SMA.sma(15)
    |> Enum.map(&(Float.round(&1, 2)))
  end
end

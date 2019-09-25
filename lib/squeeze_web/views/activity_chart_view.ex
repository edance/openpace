defmodule SqueezeWeb.ActivityChartView do
  use SqueezeWeb, :view

  alias Squeeze.{Distances, Velocity}

  def altitude(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.map(&(Distances.to_feet(&1.altitude, imperial: imperial)))
    |> smooth()
    |> Jason.encode!()
  end

  def cadence(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&(&1.cadence * 2))
    |> smooth()
    |> Jason.encode!()
  end

  def distance(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.map(&(Distances.to_float(&1.distance, imperial: imperial)))
    |> smooth()
    |> Jason.encode!()
  end

  def heartrate(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&(&1.heartrate))
    |> smooth()
    |> Jason.encode!()
  end

  def velocity(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.map(&(Velocity.to_float(&1.velocity, imperial: imperial)))
    |> smooth()
    |> Jason.encode!()
  end

  defp smooth(points) do
    points
    |> SMA.sma(15)
    |> Enum.map(&(Float.round(&1, 2)))
  end
end

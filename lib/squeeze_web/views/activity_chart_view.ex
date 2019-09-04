defmodule SqueezeWeb.ActivityChartView do
  use SqueezeWeb, :view

  alias Squeeze.{Distances, Velocity}

  def json(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.map(&(trackpoint(&1, imperial)))
  end

  def trackpoint(t, imperial) do
    %{
      altitude: Distances.to_feet(t.altitude, imperial: imperial),
      cadence: t.cadence * 2,
      distance: Distances.to_float(t.distance, imperial: imperial),
      heartrate: t.heartrate,
      velocity: Velocity.to_float(t.velocity, imperial: imperial)
    }
  end
end

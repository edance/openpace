defmodule SqueezeWeb.ActivityChartView do
  use SqueezeWeb, :view

  def json(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&(trackpoint(&1)))
  end

  def trackpoint(t) do
    %{
      altitude: t.altitude,
      cadence: t.cadence,
      distance: t.distance,
      heartrate: t.heartrate,
      velocity: t.velocity
    }
  end
end

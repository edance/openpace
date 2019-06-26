defmodule SqueezeWeb.ActivityChartView do
  use SqueezeWeb, :view

  def pace(%{current_user: _user, trackpoints: trackpoints}) do
    trackpoints
    |> map_field(:velocity)
    |> Jason.encode!()
  end

  def heartrate(%{current_user: _user, trackpoints: trackpoints}) do
    trackpoints
    |> map_field(:heartrate)
    |> Jason.encode!()
  end

  def elevation(%{current_user: _user, trackpoints: trackpoints}) do
    trackpoints
    |> map_field(:altitude)
    |> Jason.encode!()
  end

  defp map_field(trackpoints, field) do
    trackpoints
    |> Enum.map(&(%{x: Map.get(&1, :time), y: Map.get(&1, field)}))
  end
end

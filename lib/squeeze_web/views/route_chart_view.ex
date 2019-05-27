defmodule SqueezeWeb.RouteChartView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def elevation_points(assigns) do
    assigns
    |> elevation_list()
    |> Jason.encode!()
  end

  def x_ticks(%{current_user: current_user} = assigns) do
    imperial = current_user.user_prefs.imperial
    label = Distances.label(imperial: imperial)
    point = assigns
    |> elevation_list()
    |> List.last()

    %{label: label, min: 0, max: trunc(point.x) }
    |> Jason.encode!()
  end

  def y_ticks(%{current_user: current_user} = assigns) do
    imperial = current_user.user_prefs.imperial
    points = elevation_list(assigns)
    %{y: min} = points |> Enum.min_by(fn(pt) -> pt.y end)
    %{y: max} = points |> Enum.max_by(fn(pt) -> pt.y end)

    min_tick = round_down(min, imperial: imperial)
    max_tick = round_up(max, imperial: imperial)
    spread = if imperial do 500 else 100 end

    ticks = %{
      label: if imperial do "km" else "m" end,
      min: min_tick,
      max: Enum.max([min_tick + spread, max_tick])
    }
    Jason.encode!(ticks)
  end

  defp elevation_list(%{current_user: current_user, race: race}) do
    imperial = current_user.user_prefs.imperial
    race.trackpoints
    |> Enum.map(fn(x) ->
      distance = Distances.to_float(x.distance, imperial: imperial)
      altitude = Distances.to_feet(x.altitude, imperial: imperial)
      %{x: distance, y: altitude}
    end)
  end

  defp round_down(num, [imperial: true]) do
    trunc((num - 100) / 100.0) * 100
  end

  defp round_down(num, [imperial: _]) do
    trunc((num - 10) / 10.0) * 10
  end

  defp round_up(num, [imperial: true]) do
    trunc((num + 100) / 100.0) * 100
  end

  defp round_up(num, [imperial: _]) do
    trunc((num + 10) / 10.0) * 10
  end
end

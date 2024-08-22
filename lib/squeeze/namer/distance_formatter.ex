defmodule Squeeze.Namer.DistanceFormatter do
  @moduledoc """
  This module formats the distance
  """

  # 1 mile == 1609 meters
  @mile_in_meters 1_609
  @yard_in_meters 0.9144

  def format(%{type: "Swim", distance: distance}, opts) do
    to_yards_or_meters(distance, opts)
  end

  def format(%{distance: distance}, _) when distance == 0 or is_nil(distance), do: nil

  def format(%{distance: distance}, opts) do
    to_miles_or_kilometers(distance, opts)
  end

  defp to_yards_or_meters(distance, imperial: false) do
    "#{distance} m"
  end

  defp to_yards_or_meters(distance, imperial: _) do
    "#{round(distance / @yard_in_meters)} yd"
  end

  defp to_miles_or_kilometers(distance, imperial: true) do
    "#{round_distance(distance / @mile_in_meters)} mi"
  end

  defp to_miles_or_kilometers(distance, imperial: _) do
    "#{round_distance(distance / 1_000)} km"
  end

  defp round_distance(num), do: Float.round(num, 1)
end

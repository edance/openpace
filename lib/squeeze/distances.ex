defmodule Squeeze.Distances do
  @moduledoc """
  This module defines the distances used in forms.
  """

  @distances [
    %{name: "5k", distance: 5_000},
    %{name: "10k", distance: 10_000},
    %{name: "Half Marathon", distance: 21_097},
    %{name: "Marathon", distance: 42_195},
  ]

  @mile_in_meters 1_609 # 1 mile == 1609 meters

  def mile_in_meters, do: @mile_in_meters

  def to_feet(distance, [imperial: false]), do: distance
  def to_feet(distance, [imperial: _]), do: round_distance(distance * 3.28)

  def to_float(distance, [imperial: true]), do: round_distance(distance / mile_in_meters())
  def to_float(distance, [imperial: _]), do: round_distance(distance / 1_000)

  def to_int(distance, [imperial: true]), do: trunc(distance / mile_in_meters())
  def to_int(distance, [imperial: _]), do: trunc(distance / 1_000)

  def format(distance, opts), do: "#{to_float(distance, opts)} #{label(opts)}"
  def format(distance), do: format(distance, imperial: false)

  def distances, do: @distances

  def to_meters(nil, _), do: 0
  def to_meters(distance, :mi), do: distance * @mile_in_meters
  def to_meters(distance, :km), do: distance * 1000
  def to_meters(distance, _), do: distance

  def parse({distance, "mi"}), do: {:ok, distance * @mile_in_meters}
  def parse({distance, "mile"}), do: {:ok, distance * @mile_in_meters}
  def parse({distance, "miles"}), do: {:ok, distance * @mile_in_meters}
  def parse({distance, "m"}), do: {:ok, distance}
  def parse({distance, "k"}), do: {:ok, distance * 1000}
  def parse({distance, "km"}), do: {:ok, distance * 1000}
  def parse({multiplier, "x" <> rest}) do
    case parse(rest) do
      {:ok, distance} -> {:ok, multiplier * distance}
      {:error} -> {:error}
    end
  end
  def parse({_distance, ""}), do: {:error}
  def parse(str) when is_binary(str) do
    str
    |> remove_whitespace()
    |> Integer.parse()
    |> parse()
  end
  def parse(_), do: {:error}

  defp remove_whitespace(str) do
    str |> String.replace(" ", "")
  end

  defp round_distance(num), do: Float.round(num, 2)

  def label([imperial: true]), do: "mi"
  def label([imperial: _]), do: "km"
end

defmodule Squeeze.Distances do
  @moduledoc """
  This module defines the distances used in forms.
  """

  alias Number.Delimit

  # 1 mile == 1609 meters
  @mile_in_meters 1_609
  @half_marathon_in_meters 21_097
  @marathon_in_meters 42_195

  @distances [
    %{name: "5k", distance: 5_000},
    %{name: "8k", distance: 8_000},
    %{name: "10k", distance: 10_000},
    %{name: "12k", distance: 12_000},
    %{name: "15k", distance: 15_000},
    %{name: "10 Mile", distance: @mile_in_meters * 10},
    %{name: "20k", distance: 20_000},
    %{name: "Half Marathon", distance: @half_marathon_in_meters},
    %{name: "25k", distance: 25_000},
    %{name: "30k", distance: 30_000},
    %{name: "Marathon", distance: @marathon_in_meters},
    %{name: "50k", distance: 50_000},
    %{name: "50 Mile", distance: @mile_in_meters * 50},
    %{name: "100k", distance: 100_000},
    %{name: "100 Mile", distance: @mile_in_meters * 100}
  ]

  def mile_in_meters, do: @mile_in_meters
  def half_marathon_in_meters, do: @half_marathon_in_meters
  def marathon_in_meters, do: @marathon_in_meters

  def to_feet(nil, _), do: 0
  def to_feet(distance, imperial: false), do: distance
  def to_feet(distance, imperial: _), do: round_distance(distance * 3.28)

  def to_float(nil, _), do: 0.0
  def to_float(distance, imperial: true), do: round_distance(distance / mile_in_meters())
  def to_float(distance, imperial: _), do: round_distance(distance / 1_000)

  def to_int(nil, _), do: 0
  def to_int(distance, imperial: true), do: trunc(distance / mile_in_meters())
  def to_int(distance, imperial: _), do: trunc(distance / 1_000)

  def format(distance), do: format(distance, imperial: true)

  def format(distance, opts) do
    d =
      to_float(distance, opts)
      |> Delimit.number_to_delimited(precision: 2)

    "#{d} #{label(opts)}"
  end

  def distances, do: @distances

  def distance_name(distance, opts) do
    dist_obj = Enum.find(@distances, &(&1.distance == distance))

    if dist_obj do
      dist_obj.name
    else
      format(distance, opts)
    end
  end

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

  def label(imperial: true), do: "mi"
  def label(imperial: _), do: "km"
end

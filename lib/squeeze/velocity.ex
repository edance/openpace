defmodule Squeeze.Velocity do
  @moduledoc """
  This module defines the distances used in forms.
  """

  alias Squeeze.Distances

  @doc """
  Takes velocity in meters per second and converts it to either minutes per
  mile or minutes per kilometer

  ## Examples

  iex> to_float(3.2, imperial: true)
  8.38 # minutes per mile

  iex> to_float(3.2, imperial: false)
  5.20 # minutes per kilometer
  """
  def to_float(velocity, _) when velocity == 0, do: 0.0
  def to_float(velocity, imperial: true) do
    round_velocity(Distances.mile_in_meters() / 60 / velocity)
  end
  def to_float(velocity, imperial: false) do
    round_velocity(1_000 / 60 / velocity)
  end
  def to_float(velocity), do: to_float(velocity, imperial: false)

  defp round_velocity(num), do: Float.round(num, 2)
end

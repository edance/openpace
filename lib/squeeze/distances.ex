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

  def distances do
    @distances
  end

  def from_meters(meters) do
    @distances
    |> Enum.find(fn(x) -> x.distance == meters end)
  end
end

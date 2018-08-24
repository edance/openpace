defmodule Squeeze.Distances do
  @distances [
    %{name: "5k", distance: 5000},
    %{name: "10k", distance: 10000},
    %{name: "Half Marathon", distance: 21097},
    %{name: "Marathon", distance: 42195},
  ]

  def distances do
    @distances
  end

  def from_meters(meters) do
    @distances
    |> Enum.find(fn(x) -> x.distance == meters end)
  end
end

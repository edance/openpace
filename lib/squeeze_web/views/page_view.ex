defmodule SqueezeWeb.PageView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Juice up your run"
  end

  def distances() do
    Squeeze.Distances.distances
    |> Enum.map(fn(x) -> {x.name, x.distance} end)
  end
end

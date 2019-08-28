defmodule SqueezeWeb.OnboardView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def title(_page, _assigns) do
    "Build your profile"
  end

  def distances do
    Distances.distances
    |> Enum.map(fn(x) -> {x.name, x.distance} end)
  end
end

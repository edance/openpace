defmodule SqueezeWeb.PageView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def title(_page, _assigns) do
    "Juice up your run"
  end

  def distances do
    Distances.distances
    |> Enum.map(fn(x) -> {x.name, x.distance} end)
  end

  def company_name, do: "Squeeze.Run"
  def website_name, do: "Squeeze.Run"
  def website_url, do: "https://squeeze.run"
end

defmodule SqueezeWeb.RaceView do
  use SqueezeWeb, :view

  def title(_page, %{race: race}), do: race.name

  def h1(%{race: race}), do: race.name

  def location(%{race: race}) do
    "#{race.city}, #{race.state}, #{race.country}"
  end
end

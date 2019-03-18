defmodule SqueezeWeb.RaceView do
  use SqueezeWeb, :view

  def title(_page, %{race: race}), do: race.name
end

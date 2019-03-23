defmodule SqueezeWeb.RaceView do
  use SqueezeWeb, :view

  def title(_page, %{race: race}), do: race.name

  def h1(%{race: race}), do: race.name

  def location(%{race: race}) do
    "#{race.city}, #{race.state} #{race.country}"
  end

  def date(%{race: race}) do
    start_at = race.start_at
    start_at
    |> Timex.format!("%a %b #{Ordinal.ordinalize(start_at.day)}, %Y", :strftime)
  end

  def distance_type(%{race: race}) do
    race.distance_type
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end

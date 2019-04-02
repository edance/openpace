defmodule SqueezeWeb.RaceView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

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

  def time(%{race: race}) do
    race.start_at
    |> Timex.format!("%-I:%M %p ", :strftime)
  end

  def distance(%{race: %{distance: distance, country: country}}) do
    Distances.format(distance, imperial: country == "US")
  end

  def start_at(%{race: race}) do
    race.start_at
    |> Timex.to_datetime(race.timezone)
    |> DateTime.to_iso8601()
  end

  def countdown_timer(%{race: race}) do
    date = Timex.to_datetime(race.start_at, race.timezone)
    distance = Timex.diff(date, Timex.now, :seconds)
    days = trunc(distance / (60 * 60 * 24))
    hours = trunc(rem(distance, (60 * 60 * 24)) / (60 * 60))
    minutes = trunc(rem(distance, (60 * 60)) / 60)
    seconds = rem(distance, 60)
    "#{days}d #{hours}h #{minutes}m #{seconds}s"
  end

  def distance_type(%{race: race}) do
    race.distance_type
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def coordinates(%{race: race}) do
    race.trackpoints
    |> Enum.map(fn(x) -> x.coordinates end)
    |> Enum.map(fn(c) -> [c["lon"], c["lat"]] end)
    |> Poison.encode!()
  end

  def content(%{race: %{content: content}}) do
    content
    |> Earmark.as_html!()
    |> raw()
  end
end

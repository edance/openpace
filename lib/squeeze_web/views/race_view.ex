defmodule SqueezeWeb.RaceView do
  use SqueezeWeb, :view

  def title(_page, %{race: race}), do: race.name

  def location(%{race: race}) do
    "#{race.city}, #{race.state} #{race.country}"
  end

  def date(assigns) do
    start_at = start_at(assigns)
    start_at
    |> Timex.format!("%a %b #{Ordinal.ordinalize(start_at.day)}, %Y", :strftime)
  end

  def time(assigns) do
    assigns
    |> start_at
    |> Timex.format!("%-I:%M %p ", :strftime)
  end

  def start_at(%{race: race}) do
    race.events
    |> Enum.map(&(&1.start_at))
    |> Enum.min(fn -> nil end)
  end

  def content(%{race: %{content: content}}) do
    content
    |> HtmlSanitizeEx.basic_html()
    |> raw()
  end
end

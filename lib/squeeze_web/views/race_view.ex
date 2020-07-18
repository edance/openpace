defmodule SqueezeWeb.RaceView do
  use SqueezeWeb, :view

  alias Number.Delimit
  alias Squeeze.Regions

  def title(_page, %{race: race}), do: race.name

  def location(%{race: race}) do
    "#{race.city}, #{race.state} #{race.country}"
  end

  def region(%{race: race}) do
    region = Regions.from_short_name(race.state)
    region.long_name
  end

  def dates(%{race: race}) do
    race.result_summaries
    |> Enum.map(&(&1.start_date))
    |> Enum.uniq()
  end

  def grouped_results(%{race: race}) do
    @race.result_summaries
    |> Enum.group_by(&(&1.distance_name))
  end

  def format_finishers(%{finisher_count: count}) do
    "#{Delimit.number_to_delimited(count, precision: 0)} finishers"
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

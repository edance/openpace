defmodule SqueezeWeb.Races.UpcomingRacesCard do
  use SqueezeWeb, :live_component

  def race_date(%{start_date: date}) do
    date
    |> Timex.format!("%B #{Ordinal.ordinalize(date.day)}, %Y", :strftime)
  end
end

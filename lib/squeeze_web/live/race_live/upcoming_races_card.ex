defmodule SqueezeWeb.RaceLive.UpcomingRacesCard do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.Distances

  @colors ~w(
    blue
    indigo
    purple
    red
    orange
    green
    teal
    cyan
  )

  def race_date(%{start_date: date}) do
    date
    |> Timex.format!("%B #{Ordinal.ordinalize(date.day)}, %Y", :strftime)
  end

  def bg_color(model) do
    idx = rem(model.id, length(@colors))
    color = Enum.at(@colors, idx)
    "bg-gradient-#{color}"
  end

  def distance_name(distance, current_user) do
    Distances.distance_name(distance, imperial: current_user.user_prefs.imperial)
  end
end

defmodule SqueezeWeb.RaceLive.UpcomingRacesCard do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.Distances

  @colors ~w(
    bg-blue-500
    bg-indigo-500
    bg-purple-500
    bg-red-500
    bg-orange-500
    bg-green-500
    bg-teal-500
    bg-cyan-500
  )

  def race_date(%{race_date: date}) do
    date
    |> Timex.format!("%B #{Ordinal.ordinalize(date.day)}, %Y", :strftime)
  end

  def bg_color(model) do
    idx = rem(model.id, length(@colors))
    Enum.at(@colors, idx)
  end

  def distance_name(distance, current_user) do
    Distances.distance_name(distance, imperial: current_user.user_prefs.imperial)
  end
end

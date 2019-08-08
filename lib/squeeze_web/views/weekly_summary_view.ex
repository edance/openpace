defmodule SqueezeWeb.WeeklySummaryView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def weeks_until_race(%{current_user: user, dates: dates}) do
    race_date = user.user_prefs.race_date
    date = List.first(dates)
    days_left = Timex.diff(race_date, date, :days)

    if days_left > 0 do
      div(days_left, 7)
    else
      div(days_left, 7) - 1
    end
  end

  def planned_distance(%{activities: activities, current_user: user}) do
    activities
    |> Enum.map(&(Distances.to_meters(&1.planned_distance, &1.planned_distance_unit)))
    |> Enum.sum()
    |> Distances.to_float(imperial: user.user_prefs.imperial)
  end

  def completed_distance(%{activities: activities, current_user: user}) do
    activities
    |> Enum.map(&(Distances.to_meters(&1.distance, &1.distance_unit)))
    |> Enum.sum()
    |> Distances.to_float(imperial: user.user_prefs.imperial)
  end

  def progress(assigns) do
    trunc(completed_distance(assigns) / planned_distance(assigns) * 100)
  end

  def progress_bar_style(assigns) do
    "width: #{progress(assigns)}%;"
  end

  def distance_label(%{current_user: user}) do
    Distances.label(imperial: user.user_prefs.imperial)
  end
end

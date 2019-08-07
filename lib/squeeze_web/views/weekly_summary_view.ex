defmodule SqueezeWeb.WeeklySummaryView do
  use SqueezeWeb, :view

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

  def planned_distance(_) do
    0
  end

  def distance(_) do
    0
  end

  def progress(assigns) do
    trunc(distance(assigns) / planned_distance(assigns) * 100)
  end

  def progress_bar_style(assigns) do
    "width: #{progress(assigns)}%;"
  end
end

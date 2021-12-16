defmodule SqueezeWeb.Dashboard.CardsComponent do
  use SqueezeWeb, :live_component

  alias Squeeze.Accounts.User
  alias Squeeze.Distances
  alias Squeeze.TimeHelper

  def format_goal(user) do
    user.user_prefs.duration
    |> format_duration()
  end

  def improvement_amount(%User{} = user), do: User.improvement_amount(user)

  def race_date(%User{user_prefs: %{race_date: nil}}), do: nil
  def race_date(%User{user_prefs: %{race_date: date}}) do
    date
    |> Timex.format!("%b #{Ordinal.ordinalize(date.day)}", :strftime)
  end

  def weeks_until_race(%User{user_prefs: %{race_date: nil}}), do: nil
  def weeks_until_race(%User{user_prefs: %{race_date: date}} = user) do
    relative_date(user, date)
  end

  def streak(%{run_dates: dates, current_user: user}) do
    today = TimeHelper.today(user)
    yesterday = Timex.shift(today, days: -1)
    most_recent_date = List.first(dates)
    if today == most_recent_date || yesterday == most_recent_date do
      streak = dates
      |> Enum.with_index()
      |> Enum.filter(fn({x, idx}) -> x == Timex.shift(most_recent_date, days: -idx) end)
      "#{length(streak)} day streak"
    else
      "0 day streak"
    end
  end

  def weekly_distance(%{activity_summaries: summaries, current_user: user}) do
    date = Timex.now()
    |> Timex.to_datetime(user.user_prefs.timezone)
    |> Timex.beginning_of_week()

    distance = summaries
    |> Enum.filter(&(Timex.after?(&1.start_at_local, date) && String.contains?(&1.type, "Run")))
    |> Enum.map(&(&1.distance))
    |> Enum.sum()

    imperial = user.user_prefs.imperial

    "#{Distances.to_float(distance, imperial: imperial)} #{Distances.label(imperial: imperial)}"
  end

  def last_week_distance(%{activity_summaries: summaries, current_user: user}) do
    start_date = Timex.now()
    |> Timex.to_datetime(user.user_prefs.timezone)
    |> Timex.shift(weeks: -1)
    |> Timex.beginning_of_week()

    end_date = start_date |> Timex.end_of_week()

    distance = summaries
    |> Enum.filter(&(Timex.between?(&1.start_at_local, start_date, end_date) && String.contains?(&1.type, "Run")))
    |> Enum.map(&(&1.distance))
    |> Enum.sum()

    imperial = user.user_prefs.imperial

    "#{Distances.to_float(distance, imperial: imperial)} #{Distances.label(imperial: imperial)}"
  end
end

defmodule SqueezeWeb.OverviewView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.Distances
  alias Squeeze.TimeHelper

  def title(_page, _assigns) do
    gettext("Dashboard")
  end

  def full_name(%User{} = user), do: User.full_name(user)

  def hometown(%User{city: city, state: state}) do
    "#{city}, #{state}"
  end

  def initials(%User{first_name: first_name, last_name: last_name}) do
    "#{String.at(first_name, 0)}#{String.at(last_name, 0)}"
  end

  def improvement_amount(%User{} = user), do: User.improvement_amount(user)

  def format_goal(user) do
    user.user_prefs.duration
    |> format_duration()
  end

  def race_date(%User{user_prefs: %{race_date: nil}}), do: nil
  def race_date(%User{user_prefs: %{race_date: date}}) do
    date
    |> Timex.format!("%b #{Ordinal.ordinalize(date.day)}", :strftime)
  end

  def weeks_until_race(%User{user_prefs: %{race_date: nil}}), do: nil
  def weeks_until_race(%User{user_prefs: %{race_date: date}} = user) do
    relative_date(user, date)
  end

  def weekly_distance(%{year_dataset: dataset, current_user: user}) do
    distance = dataset
    |> List.last()
    |> Map.get(:distance)
    "#{distance} #{Distances.label(imperial: user.user_prefs.imperial)}"
  end

  def last_week_distance(%{year_dataset: dataset, current_user: user}) do
    distance = dataset
    |> Enum.reverse()
    |> Enum.at(1)
    |> Map.get(:distance)
    "#{distance} #{Distances.label(imperial: user.user_prefs.imperial)}"
  end

  def dates(assigns) do
    today = today(assigns)
    end_date = Timex.end_of_week(today)
    start_date = today |> Timex.shift(weeks: -4) |> Timex.beginning_of_week()
    Date.range(start_date, end_date)
  end

  def today(%{current_user: user}) do
    TimeHelper.today(user)
  end

  def active_on_date?(%{run_dates: dates}, date) do
    dates
    |> Enum.member?(date)
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
end

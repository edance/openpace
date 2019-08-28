defmodule SqueezeWeb.OverviewView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.Distances
  alias Squeeze.TimeHelper

  def title(_page, _assigns) do
    gettext("Dashboard")
  end

  def full_name(%User{} = user), do: User.full_name(user)

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

  def weekly_diff(%{year_dataset: dataset}) do
    distances = dataset
    |> Enum.reverse()
    |> Enum.map(&(&1.distance))

    curr_distance = Enum.at(distances, 0)
    prev_distance = Enum.at(distances, 1)
    if prev_distance == 0 do
      nil
    else
      percent = (curr_distance - prev_distance) / prev_distance * 100
      trunc(percent)
    end
  end

  def streak(%{activities: activities, current_user: user}) do
    today = TimeHelper.today(user)
    yesterday = Timex.shift(today, days: -1)
    dates = activities
    |> Enum.filter(&(String.contains?(&1.type, "Run")))
    |> Enum.map(&(TimeHelper.to_date(user, &1.start_at)))
    |> Enum.uniq()
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

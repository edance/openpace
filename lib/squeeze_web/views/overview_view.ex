defmodule SqueezeWeb.OverviewView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.TimeHelper

  def title(_page, _assigns) do
    "Dashboard"
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

  def weekly_distance(%User{} = user, activities) do
    today = TimeHelper.today(user)
    date = Timex.shift(today, days: -Timex.days_to_beginning_of_week(today))
    activities
    |> Enum.filter(fn(x) -> Timex.after?(x.start_at, date) end)
    |> Enum.map(&(&1.distance))
    |> Enum.sum()
    |> format_distance(user.user_prefs)
  end
end

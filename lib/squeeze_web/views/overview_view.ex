defmodule SqueezeWeb.OverviewView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.Distances
  alias Squeeze.TimeHelper

  @mapbox_token Application.get_env(:squeeze, :mapbox_access_token)

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

  def activity_img_src(%{polyline: polyline}) do
    base_url = "https://api.mapbox.com/styles/v1/mapbox/light-v9/static/"
    stroke_color = "5e72e4"
    stroke_width = "5"
    stroke_opacity = "0.7"
    size = "300x200"
    polyline = URI.encode_www_form(polyline)
    path = "path-#{stroke_width}+#{stroke_color}-#{stroke_opacity}(#{polyline})"
    "#{base_url}#{path}/auto/#{size}?access_token=#{@mapbox_token}"
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

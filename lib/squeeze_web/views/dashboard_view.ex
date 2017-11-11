defmodule SqueezeWeb.DashboardView do
  use SqueezeWeb, :view

  def title("index.html", _) do
    "Dashboard"
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def city_state(user) do
    "#{user.city}, #{user.state}"
  end

  def goal_time(goal) do
    duration = goal.duration
    hours = div(duration, 3600)
    minutes = div((duration - hours * 3600), 60)
    seconds = rem(duration, 60)
    "#{hours}:#{minutes}:#{seconds}"
  end

  def goal_pace(goal) do
    # min / mile
    miles = goal.distance / 1609
    pace = round(goal.duration / miles)
    minutes = div(pace, 60)
    seconds = rem(pace, 60)
    secs = if seconds < 10, do: "0#{seconds}", else: seconds
    "#{minutes}:#{secs}/mi"
  end
end

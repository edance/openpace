defmodule SqueezeWeb.SidebarView do
  use SqueezeWeb, :view

  alias Timex.Duration

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def goal_time(goal) do
    duration = Duration.from_seconds(goal.duration)
    Duration.to_time!(duration)
    |> Timex.format!(format(duration), :strftime)
  end

  def format(duration) do
    case Duration.to_hours(duration) do
      x when x < 1 -> "%-M:%S"
      _ -> "%-H:%M:%S"
    end
  end
end

defmodule SqueezeWeb.SidebarView do
  use SqueezeWeb, :view

  alias Timex.Duration

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def goal_time(goal) do
    Duration.from_seconds(goal.duration)
    |> Duration.to_time!()
    |> Timex.format!("%H:%M:%S", :strftime)
  end
end

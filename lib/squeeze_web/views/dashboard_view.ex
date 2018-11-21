defmodule SqueezeWeb.DashboardView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  require IEx

  def title(_page, _assigns) do
    "Dashboard"
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def goal_card_title(user) do
    distance = user.user_prefs.distance
    %{name: name} = Distances.from_meters(distance)
    "#{name} Goal"
  end

  def format_goal(user) do
    user.user_prefs.duration
    |> format_duration()
  end

  def format_date(user) do
    user.user_prefs.race_date
    |> relative_time()
  end
end

defmodule SqueezeWeb.PlanView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Build your training plan"
  end

  def events_for_date(events, week, day) do
    position = (week - 1) * 7 + day - 1

    events
    |> Enum.filter(&(&1.plan_position == position))
    |> Enum.sort_by(&(&1.day_position))
  end
end

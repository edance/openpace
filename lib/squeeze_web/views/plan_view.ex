defmodule SqueezeWeb.PlanView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Build your training plan"
  end

  def day_name(date) do
    date
    |> Timex.weekday()
    |> Timex.day_name()
  end
end

defmodule SqueezeWeb.EventView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Events"
  end

  def day_name(date) do
    date
    |> Timex.weekday()
    |> Timex.day_name()
  end
end

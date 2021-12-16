defmodule SqueezeWeb.Dashboard.MiniCalendarComponent do
  use SqueezeWeb, :live_component

  alias Squeeze.TimeHelper

  def active_on_date?(%{activity_map: activity_map}, date) do
    list = Map.get(activity_map, date, [])
    !Enum.empty?(list)
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
end

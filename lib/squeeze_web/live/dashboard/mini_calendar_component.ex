defmodule SqueezeWeb.Dashboard.MiniCalendarComponent do
  use SqueezeWeb, :live_component

  alias Squeeze.TimeHelper

  def data(%{activity_map: activity_map} = assigns) do
    dates(assigns)
    |> Enum.map(fn(date) ->
      %{
        date: date,
        activities: Map.get(activity_map, date, [])
      }
    end)
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

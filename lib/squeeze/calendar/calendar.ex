defmodule Squeeze.Calendar do
  @moduledoc """
  Calendar module to help with visible_dates of calendar and other helper functions.
  """

  @doc """
  Get visible dates for a calendar based on `type` which can either be "day" or "month".

  Returns a date range based of of the `base` day and the `type`.

  - "day" - the previous day and the following day
  - "month" - returns a date range starting with the Monday on the first week of the month and the Sunday of the last week of the month

  """
  def visible_dates(base, type) do
    Date.range(first_date(base, type), last_date(base, type))
  end

  defp first_of_month(base) do
    {:ok, date} = Date.new(base.year, base.month, 1)
    date
  end

  defp last_day_of_month(base) do
    days = Date.days_in_month(base)
    {:ok, date} = Date.new(base.year, base.month, days)
    date
  end

  defp first_date(date, "day"), do: Date.add(date, -1)
  defp first_date(base, "month") do
    date = first_of_month(base)
    case Date.day_of_week(date) do
      1 -> date
      x -> Date.add(date, -(x - 1))
    end
  end

  defp last_date(date, "day"), do: Date.add(date, 1)
  defp last_date(base, "month") do
    date = last_day_of_month(base)
    case Date.day_of_week(date) do
      1 -> Date.add(date, 6)
      x -> Date.add(date, 7 - x)
    end
  end
end

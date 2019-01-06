defmodule Squeeze.Calendar do
  @moduledoc """
  The Calendar context.
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

  defp first_date(date, "short"), do: Date.add(date, -1)
  defp first_date(base, "month") do
    date = first_of_month(base)
    case Date.day_of_week(date) do
      1 -> date
      x -> Date.add(date, -(x - 1))
    end
  end

  defp last_date(date, "short"), do: Date.add(date, 1)
  defp last_date(base, "month") do
    date = last_day_of_month(base)
    case Date.day_of_week(date) do
      1 -> Date.add(date, 6)
      x -> Date.add(date, 7 - x)
    end
  end
end

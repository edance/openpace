defmodule Squeeze.Calendar do
  @moduledoc """
  The Calendar context.
  """

  def visible_dates(base) do
    Date.range(first_date(base), last_date(base))
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

  # 7 is Sunday in elxir
  defp first_date(base) do
    date = first_of_month(base)
    day_of_week = Date.day_of_week(date)
    if day_of_week == 7 do
      date
    else
     Date.add(date, -day_of_week)
    end
  end

  # Last day is 6 Saturday
  defp last_date(base) do
    date = last_day_of_month(base)
    day_of_week = Date.day_of_week(date)
    if day_of_week == 7 do
      Date.add(date, 6)
    else
      Date.add(date, 6 - day_of_week)
    end
  end
end


defmodule SqueezeWeb.CalendarView do
  use SqueezeWeb, :view

  def previous(base) do
    {:ok, date} = subtract_month(base)
    format_date(date)
  end

  def next(base) do
    {:ok, date} = add_month(base)
    format_date(date)
  end

  def first_of_month(base) do
    {:ok, date} = Date.new(base.year, base.month, 1)
    date
  end

  def last_day_of_month(base) do
    days = Date.days_in_month(base)
    {:ok, date} = Date.new(base.year, base.month, days)
    date
  end

  def dates(base) do
    Date.range(first_date(base), last_date(base))
  end

  # 7 is Sunday in elxir
  def first_date(base) do
    date = first_of_month(base)
    day_of_week = Date.day_of_week(date)
    if day_of_week == 7 do
      date
    else
     Date.add(date, -day_of_week)
    end
  end

  # Last day is 6 Saturday
  def last_date(base) do
    date = last_day_of_month(base)
    day_of_week = Date.day_of_week(date)
    if day_of_week == 7 do
      Date.add(date, 6)
    else
      Date.add(date, 6 - day_of_week)
    end
  end

  def add_month(date) do
    case date.month do
      12 -> Date.new(date.year + 1, 1, 1)
      x -> Date.new(date.year, x + 1, 1)
    end
  end

  def subtract_month(date) do
    case date.month do
      1 -> Date.new(date.year - 1, 12, 1)
      x -> Date.new(date.year, x - 1, 1)
    end
  end

  def format_date(date) do
    Timex.format!(date, "{YYYY}-{0M}-{0D}")
  end
end

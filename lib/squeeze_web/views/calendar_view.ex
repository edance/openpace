defmodule SqueezeWeb.CalendarView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Calendar"
  end

  def previous_short(base) do
    date = Date.add(base, -3)
    format_date(date)
  end

  def next_short(base) do
    date = Date.add(base, 3)
    format_date(date)
  end

  def previous_month(base) do
    {:ok, date} = subtract_month(base)
    format_date(date)
  end

  def next_month(base) do
    {:ok, date} = add_month(base)
    format_date(date)
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

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

  # First row
  def date_label(date, idx) when idx < 7 do
    content_tag(:div) do
      [
        Timex.format!(date, "%a", :strftime),
        date_label(date)
      ]
    end
  end

  def date_label(date, idx) do
    date_label(date)
  end

  defp date_label(date) do
    content_tag(:div, class: "date-label", data: [date: format_date(date)]) do
      date.day
    end
  end

  def class_list(idx, dates) do
    class_list = ["calendar-date"]
    if !last_column?(idx) do
      class_list = class_list ++ ["border-right"]
    end
    unless last_row?(idx, dates) do
      class_list = class_list ++ ["border-bottom"]
    end
    Enum.join(class_list, " ")
  end

  defp last_column?(idx), do: rem(idx, 7) == 6
  defp last_row?(idx, dates), do: (Enum.count(dates) - idx) <= 7
end

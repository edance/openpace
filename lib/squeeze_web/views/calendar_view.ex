defmodule SqueezeWeb.CalendarView do
  use SqueezeWeb, :view

  alias Squeeze.TimeHelper

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

  def date_label(date, idx) when idx < 7 do
    content_tag(:div) do
      [
        Timex.format!(date, "%a", :strftime),
        date_label(date)
      ]
    end
  end

  def date_label(date, _idx) do
    date_label(date)
  end

  defp date_label(date) do
    content_tag(:div, class: "date-label", data: [date: format_date(date)]) do
      date_label_content(date)
    end
  end

  def activity_color(%{status: :pending}), do: "info"
  def activity_color(%{status: :complete}), do: "success"
  def activity_color(%{status: :incomplete}), do: "danger"
  def activity_color(%{status: :partial}), do: "warning"

  def on_date?(user, date, activity) do
    activity.planned_date == date ||
      TimeHelper.to_date(user, activity.start_at)  == date
  end

  defp date_label_content(date) do
    if date.day == 1 do
      Timex.format!(date, "%b %-d", :strftime)
    else
      date.day
    end
  end

  def class_list(idx, dates) do
    class_list = ["calendar-date p-1"]
    class_list =
      case last_column?(idx) do
        true ->  class_list
        false -> class_list ++ ["border-right"]
      end
    class_list =
      case last_row?(idx, dates) do
        true -> class_list
        false -> class_list ++ ["border-bottom"]
      end
    Enum.join(class_list, " ")
  end

  defp last_column?(idx), do: rem(idx, 7) == 6
  defp last_row?(idx, dates), do: (Enum.count(dates) - idx) <= 7
end

defmodule SqueezeWeb.CalendarView do
  use SqueezeWeb, :view

  alias Squeeze.TimeHelper

  def title(_page, _assigns) do
    "Calendar"
  end

  def prev(base, "day"), do: shift(base, days: -1)
  def prev(base, "month"), do: shift(base, months: -1)

  def next(base, "day"), do: shift(base, days: 1)
  def next(base, "month"), do: shift(base, months: 1)

  defp format_date(date), do: Timex.format!(date, "{YYYY}-{0M}-{0D}")

  defp shift(date, opts), do: date |> Timex.shift(opts) |> format_date()

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

  def date_label(date) do
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

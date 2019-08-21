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

  def weeks(%{dates: dates}) do
    dates
    |> Enum.with_index()
    |> Enum.group_by(fn({_, idx}) -> div(idx, 7) end, fn({v, _}) -> v end)
  end

  def activities_in_dates(user, activities, dates) do
    activities
    |> Enum.filter(&(Enum.member?(dates, activity_date(user, &1))))
  end

  defp format_date(date), do: Timex.format!(date, "{YYYY}-{0M}-{0D}")

  defp shift(date, opts), do: date |> Timex.shift(opts) |> format_date()

  def date_label(date) do
    content_tag(:div, class: "date-label", data: [date: format_date(date)]) do
      date_label_content(date)
    end
  end

  defp date_label_content(date) do
    if date.day == 1 do
      Timex.format!(date, "%a, %b %-d", :strftime)
    else
      Timex.format!(date, "%a, %b %-d", :strftime)
    end
  end

  defp activity_date(user, activity) do
    activity.planned_date || TimeHelper.to_date(user, activity.start_at)
  end
end

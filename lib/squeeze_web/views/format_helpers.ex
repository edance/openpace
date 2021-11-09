defmodule SqueezeWeb.FormatHelpers do
  @moduledoc """
  This module defines helpers common running related formatting like pace,
  distance, duration.
  """

  use Phoenix.HTML

  alias Squeeze.Accounts.{User, UserPrefs}
  alias Squeeze.Distances
  alias Squeeze.Duration
  alias Squeeze.TimeHelper

  @doc """
  Formats a duration like a stopwatch

  ## Examples

    iex> format_duration(duration)
    "3:00:00"
  """
  def format_duration(t), do: Duration.format(t)

  def format_distance(distance, %UserPrefs{} = user_prefs) do
    Distances.format(distance, imperial: user_prefs.imperial)
  end

  def relative_date(%User{} = user, date) do
    relative_date(Timex.diff(date, TimeHelper.today(user), :days))
  end

  defp relative_date(-1), do: "yesterday"
  defp relative_date(0), do: "today"
  defp relative_date(1), do: "tomorrow"
  defp relative_date(diff_in_days) when diff_in_days > 0 do
    case abs(diff_in_days) do
      x when x <= 14 -> "in #{format_plural(x, "day")}"
      x when rem(x, 7) == 0 -> "in #{format_plural(div(x, 7), "wk")}"
      x -> "in #{div(x, 7)} wks, #{format_plural(rem(x, 7), "day")}"
    end
  end
  defp relative_date(diff_in_days) do
    case abs(diff_in_days) do
      x when x <= 14 -> "#{format_plural(x, "day")} ago"
      x when rem(x, 7) == 0 -> "#{format_plural(div(x, 7), "wk")} ago"
      x -> "#{div(x, 7)} wks, #{format_plural(rem(x, 7), "day")} ago"
    end
  end

  def relative_time(nil), do: nil
  def relative_time(time) do
    Timex.format!(time, "{relative}", :relative)
  end

  defp format_plural(1, suffix), do: "1 #{suffix}"
  defp format_plural(count, suffix), do: "#{count} #{suffix}s"

  def format_pace(%{distance: distance}, _) when distance <= 0, do: "N/A"
  def format_pace(%{distance: distance, duration: duration}, %UserPrefs{} = user_prefs) do
    miles = Distances.to_float(distance, imperial: user_prefs.imperial)
    label = Distances.label(imperial: user_prefs.imperial)
    pace = trunc(duration / miles)
    "#{format_duration(pace)}/#{label}"
  end

  def format_ordinal_date(date) do
    Timex.format!(date, "%b #{Ordinal.ordinalize(date.day)}", :strftime)
  end
end

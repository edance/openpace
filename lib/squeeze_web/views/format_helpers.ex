defmodule SqueezeWeb.FormatHelpers do
  @moduledoc """
  This module defines helpers common running related formatting like pace,
  distance, duration.
  """

  use Phoenix.HTML

  alias Squeeze.Accounts.{User, UserPrefs}
  alias Squeeze.Distances
  alias Squeeze.TimeHelper
  alias Timex.Duration

  @doc """
  Formats a duration like a stopwatch

  ## Examples

    iex> format_duration(duration)
    "3:00:00"
  """
  def format_duration(nil), do: nil
  def format_duration(seconds) do
    duration = Duration.from_seconds(seconds)
    duration
    |> Duration.to_time!()
    |> Timex.format!(format(duration), :strftime)
  end

  def format_distance(distance, %UserPrefs{} = user_prefs) do
    Distances.format(distance, imperial: user_prefs.imperial)
  end

  def relative_date(%User{} = user, date) do
    case Timex.diff(date, TimeHelper.today(user), :days) do
      0 -> "today"
      1 -> "tomorrow"
      x when x <= 14 -> "in #{format_plural(x, "day")}"
      x when rem(x, 7) == 0 -> "in #{format_plural(div(x, 7), "wk")}"
      x -> "in #{div(x, 7)} wks, #{format_plural(rem(x, 7), "day")}"
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
    pace = duration / miles
    {:ok, time} = duration_to_time(pace)
    "#{Timex.format!(time, "%-M:%S", :strftime)}/#{label}"
  end

  defp duration_to_time(duration) do
    duration
    |> Duration.from_seconds()
    |> Duration.to_time()
  end

  defp format(duration) do
    case Duration.to_hours(duration) do
      x when x < 1 -> "%-M:%S"
      _ -> "%-H:%M:%S"
    end
  end
end

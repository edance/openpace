defmodule SqueezeWeb.FormatHelpers do
  @moduledoc """
  This module defines helpers common running related formatting like pace,
  distance, duration.
  """

  use Phoenix.HTML

  alias Squeeze.Accounts.UserPrefs
  alias Squeeze.Distances
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

  def relative_date(date) do
    case Timex.diff(date, Timex.today, :days) do
      0 -> "today"
      1 -> "tomorrow"
      x when x <= 14 -> "in #{x} days"
      x -> "in #{trunc(Float.ceil(x / 7))} weeks"
    end
  end

  def relative_time(nil), do: nil
  def relative_time(time) do
    Timex.format!(time, "{relative}", :relative)
  end

  def format_pace(_, distance) when distance <= 0, do: ""
  def format_pace(duration, distance) do
    case pace_duration(duration, distance) do
      {:ok, str} -> "#{str} min/mile"
      :error -> ""
    end
  end

  defp pace_duration(duration, distance) do
    miles = distance / 1609
    pace = duration / miles
    case duration_to_time(pace) do
      {:ok, time} -> Timex.format(time, "%-M:%S", :strftime)
      {:error, _} -> :error
    end
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

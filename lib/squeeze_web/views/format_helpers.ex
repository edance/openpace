defmodule SqueezeWeb.FormatHelpers do
  @moduledoc """
  This module defines helpers common running related formatting like pace,
  distance, duration.
  """

  use Phoenix.HTML

  alias Number.Delimit
  alias Squeeze.Accounts.{User, UserPrefs}
  alias Squeeze.Distances
  alias Squeeze.Duration
  alias Squeeze.TimeHelper

  def full_name(%User{} = user), do: User.full_name(user)

  def initials(%User{first_name: first_name, last_name: last_name}) do
    "#{String.at(first_name, 0)}#{String.at(last_name, 0)}"
  end

  def hometown(%User{city: nil, state: nil}), do: nil
  def hometown(%User{city: city, state: state}) do
    "#{city}, #{state}"
  end

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

  def format_elevation_gain(elevation_gain, %UserPrefs{imperial: imperial}) do
    value = elevation_gain
    |> Distances.to_feet(imperial: imperial)
    |> Delimit.number_to_delimited(precision: 0)

    if imperial do
      "#{value} ft"
    else
      "#{value} m"
    end
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

  def format_speed(speed, user_prefs) do
    meters = if user_prefs.imperial, do: Distances.mile_in_meters(), else: 1_000
    pace = meters / speed
    label = Distances.label(imperial: user_prefs.imperial)
    "#{format_duration(pace)}/#{label}"
  end

  def format_ordinal_date(date) do
    Timex.format!(date, "%b #{Ordinal.ordinalize(date.day)}", :strftime)
  end

  def format_date_with_time(start_at) do
    date = Ordinal.ordinalize(start_at.day)
    start_at
    |> Timex.format!("%a, %b #{date}, %Y at %-I:%M %p", :strftime)
  end

  def format_number(num) do
    Delimit.number_to_delimited(num, precision: 0)
  end

  def format_score(%{challenge_type: :segment}, amount) do
    if amount > 0 do
      format_duration(amount)
    else
      "No Attempt"
    end
  end
  def format_score(challenge, amount) do
    case challenge.challenge_type do
      :distance -> Distances.format(amount)
      :time -> format_duration(amount)
      :altitude -> "#{Distances.to_feet(amount, imperial: true)} ft"
      _ -> format_duration(amount)
    end
  end

  def challenge_type(%{challenge: challenge}) do
    challenge_type(challenge.challenge_type)
  end

  def challenge_type(challenge_type) do
    case challenge_type do
      :distance -> "Distance Challenge"
      :time -> "Time Challenge"
      :altitude -> "Elevation Gain Challenge"
      :segment -> "Segment Challenge"
      _ -> "Challenge"
    end
  end

  def challenge_label(%{challenge: challenge}) do
    case challenge.challenge_type do
      :distance -> "Distance"
      :time -> "Time"
      :altitude -> "Elevation Gain"
      :segment -> "Time"
    end
  end

end

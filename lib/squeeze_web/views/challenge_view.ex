defmodule SqueezeWeb.ChallengeView do
  use SqueezeWeb, :view

  alias Squeeze.TimeHelper

  def title("show.html", %{challenge: challenge}), do: challenge.name
  def title(_, _assigns), do: "Challenges"

  def challenge_relative_date(%{challenge: challenge, current_user: user}) do
    today = TimeHelper.today(user)

    cond do
      Timex.after?(challenge.start_date, today) ->
        "Starts #{relative_time(challenge.start_date)}"
      Timex.before?(challenge.end_date, today) ->
        "Ended #{relative_time(challenge.end_date)}"
      true ->
        "Ends #{relative_time(challenge.end_date)}"
    end
  end

  def remaining_percentage(%{challenge: challenge, current_user: user}) do
    today = TimeHelper.today(user)
    start_date = challenge.start_date
    end_date = challenge.end_date

    cond do
      Timex.after?(challenge.start_date, today) -> 0.0
      Timex.before?(challenge.end_date, today) -> 100.0
      true ->
        Timex.diff(today, start_date, :seconds) / Timex.diff(end_date, start_date, :seconds) * 100.0
    end
  end

  def challenge_type(%{challenge: challenge}) do
    case challenge.challenge_type do
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

  def podium_finish(%{challenge: challenge, current_user: user}) do
    case Enum.find_index(challenge.scores, &(&1.user_id == user.id)) do
      0 -> "1st Place"
      1 -> "2nd Place"
      2 -> "3rd Place"
      _ -> nil
    end
  end

  def podium_icon(%{challenge: challenge, current_user: user}) do
    case Enum.find_index(challenge.scores, &(&1.user_id == user.id)) do
      0 -> "whh:medalgold"
      1 -> "whh:medalsilver"
      2 -> "whh:medalbronze"
      _ -> nil
    end
  end
end

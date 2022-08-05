defmodule SqueezeWeb.Challenges.PodiumCardComponent do
  use SqueezeWeb, :live_component

  alias Squeeze.TimeHelper

  def challenge_relative_date(%{challenge: challenge, current_user: user}) do
    now = Timex.now()
    start_at = TimeHelper.beginning_of_day(user, challenge.start_date)
    end_at = TimeHelper.end_of_day(user, challenge.end_date)

    cond do
      Timex.after?(start_at, now) ->
        "Starts #{relative_time(start_at)}"
      Timex.before?(end_at, now) ->
        "Ended #{relative_time(end_at)}"
      true ->
        "Ends #{relative_time(end_at)}"
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

  def avatar_size(0), do: "xl"
  def avatar_size(1), do: "lg"
  def avatar_size(_), do: "md"

  def podium_order(0), do: "col order-2"
  def podium_order(1), do: "col order-1"
  def podium_order(_), do: "col order-3"
end

defmodule SqueezeWeb.Challenges.PodiumItemComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.TimeHelper

  def podium_icon(%{challenge: challenge, current_user: user}) do
    case Enum.find_index(challenge.scores, &(&1.user_id == user.id)) do
      0 -> "whh:medalgold"
      1 -> "whh:medalsilver"
      2 -> "whh:medalbronze"
      _ -> nil
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
end

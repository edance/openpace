defmodule SqueezeWeb.ChallengeView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.Distances
  alias Squeeze.TimeHelper

  def title("show.html", %{challenge: challenge}), do: challenge.name
  def title(_, _assigns), do: "Challenges"

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

  def full_name(%User{} = user), do: User.full_name(user)

  def initials(%User{first_name: first_name, last_name: last_name}) do
    "#{String.at(first_name, 0)}#{String.at(last_name, 0)}"
  end

  def avatar_size(0), do: "avatar-xl"
  def avatar_size(1), do: "avatar-lg"
  def avatar_size(_), do: ""

  def podium_order(0), do: "order-2"
  def podium_order(1), do: "order-1"
  def podium_order(_), do: "order-3"
end

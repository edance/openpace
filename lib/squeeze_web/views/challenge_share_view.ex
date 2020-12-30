defmodule SqueezeWeb.ChallengeShareView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def title(_page, _assigns) do
    gettext("Challenge Invite")
  end

  def remaining_percentage(%{challenge: challenge}) do
    now = DateTime.utc_now()
    start_at = challenge.start_at
    end_at = challenge.end_at

    cond do
      Timex.diff(now, start_at) < 0 -> 0.0
      Timex.diff(now, end_at) > 0 -> 1 * 100.0
      true ->
        Timex.diff(now, start_at, :seconds) / Timex.diff(end_at, start_at, :seconds) * 100.0
    end
  end

  def challenge_label(%{challenge: challenge}) do
    case challenge.challenge_type do
      :distance -> "Distance"
      :time -> "Time"
      :altitude -> "Altitude"
      :segment -> "Time"
    end
  end

  def format_score(challenge, amount) do
    case challenge.challenge_type do
      :distance -> Distances.format(amount)
      :time -> format_duration(amount)
      :altitude -> "#{Distances.to_feet(amount, imperial: true)} ft"
      :segment -> format_duration(amount)
    end
  end
end

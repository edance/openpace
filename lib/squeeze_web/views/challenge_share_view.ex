defmodule SqueezeWeb.ChallengeShareView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def title(_page, _assigns) do
    gettext("Challenge Invite")
  end

  def remaining_percentage(%{challenge: challenge}) do
    now = DateTime.utc_now()
    start_date = challenge.start_date
    end_date = challenge.end_date

    cond do
      Timex.diff(now, start_date) < 0 -> 0.0
      Timex.diff(now, end_date) > 0 -> 1 * 100.0
      true ->
        Timex.diff(now, start_date, :seconds) / Timex.diff(end_date, start_date, :seconds) * 100.0
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
end

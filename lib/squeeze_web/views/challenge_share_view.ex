defmodule SqueezeWeb.ChallengeShareView do
  use SqueezeWeb, :view
  @moduledoc false

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
end

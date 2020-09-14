defmodule Squeeze.Challenges.ScoreUpdater do
  @moduledoc """
  This module takes an activity and updates the score for that user
  """

  alias Squeeze.Challenges
  alias Squeeze.Challenges.Challenge
  alias Squeeze.Dashboard.Activity

  def update_score(%Activity{user: user} = activity) do
    challenges = Challenges.list_current_challenges(user)
    challenges
    |> Enum.filter(&(match_activity?(activity, &1)))
    |> Enum.map(fn (challenge) -> update_score(activity, challenge) end)
  end

  defp update_score(%Activity{user: user} = activity, %Challenge{} = challenge) do
    score = Challenges.get_score!(user, challenge)
    amount = amount(activity, challenge)
    Challenges.update_score!(score, %{score: score.score + amount})
  end

  defp amount(%Activity{distance: amount}, %Challenge{challenge_type: :distance}) do
    amount
  end

  defp amount(%Activity{duration: amount}, %Challenge{challenge_type: :time}) do
    amount
  end

  defp amount(%Activity{elevation_gain: amount}, %Challenge{challenge_type: :altitude}) do
    amount
  end

  defp amount(%Activity{}, %Challenge{}) do
    0
  end

  defp match_activity?(activity, challenge) do
    activity.type
    |> String.downcase()
    |> String.contains?(Atom.to_string(challenge.activity_type))
  end
end

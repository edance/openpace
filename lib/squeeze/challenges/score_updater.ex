defmodule Squeeze.Challenges.ScoreUpdater do
  @moduledoc """
  This module takes an activity and updates the score for that user
  """

  alias Squeeze.Accounts.User
  alias Squeeze.Challenges
  alias Squeeze.Challenges.Challenge
  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo

  def update_score(%Activity{} = activity) do
    activity = Repo.preload(activity, :user)
    user = activity.user
    challenges = Challenges.list_current_challenges(user)
    challenges
    |> Enum.filter(&(match_activity?(activity, &1)))
    |> Enum.map(fn (challenge) -> update_score(activity, challenge) end)
  end

  defp update_score(%Activity{} = activity, %Challenge{} = challenge) do
    activity = Repo.preload(activity, :user)
    user = activity.user
    score = Challenges.get_score!(user, challenge)
    amount = amount(activity, challenge)
    Challenges.update_score!(score, %{score: score.score + amount})
  end

  def total_amount(%User{} = user, %Challenge{} = challenge) do
    sum = Dashboard.list_activities(user, challenge.start_at, challenge.end_at)
    |> Enum.map(fn(x) -> amount(x, challenge) end)
    |> Enum.sum()

    sum / 1 # always cast to float
  end

  def sync_score(%User{} = user, %Challenge{} = challenge) do
    score = Challenges.get_score!(user, challenge)
    Challenges.update_score!(score, %{score: total_amount(user, challenge)})
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
    0.0
  end

  defp match_activity?(activity, challenge) do
    activity.type
    |> String.downcase()
    |> String.contains?(Atom.to_string(challenge.activity_type))
  end
end

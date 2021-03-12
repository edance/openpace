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
  alias Squeeze.Strava.Activities

  def update_score(%Activity{} = activity) do
    challenges = Challenges.list_matched_challenges(activity)
    challenges
    |> Enum.map(fn (challenge) -> update_score(activity, challenge) end)
  end

  def update_score(%Activity{} = activity, %Challenge{} = challenge) do
    activity = Repo.preload(activity, :user)
    user = activity.user
    score = Challenges.get_score!(user, challenge)
    amount = amount(activity, challenge)

    Challenges.create_challenge_activity(challenge, activity, %{amount: amount})

    if challenge.challenge_type == :segment do
      if amount && (score.amount == 0.0 || amount < score.amount) do
        Challenges.update_score!(challenge, score, amount / 1) # cast to float

      else
        {:ok, score}
      end
    else
      Challenges.update_score!(challenge, score, score.amount + amount)
    end
  end

  def total_amount(%User{}, %Challenge{challenge_type: :segment}), do: nil
  def total_amount(%User{} = user, %Challenge{} = challenge) do
    range = Date.range(challenge.start_date, challenge.end_date)
    sum = Dashboard.list_activities(user, range)
    |> Enum.map(fn(x) -> amount(x, challenge) end)
    |> Enum.sum()

    sum / 1 # always cast to float
  end

  def amount(%Activity{external_id: external_id, user: user}, %Challenge{challenge_type: :segment, segment_id: segment_id}) do
    {:ok, strava_activity} = Activities.get_activity_by_id(user, external_id)

    best_effort = strava_activity.segment_efforts
    |> Enum.filter(fn(x) -> x.segment && to_string(x.segment.id) == segment_id end)
    |> Enum.sort_by(fn(x) -> x.elapsed_time end)
    |> List.first()

    if best_effort do
      best_effort.elapsed_time
    else
      nil
    end
  end

  def amount(%Activity{distance: amount}, %Challenge{challenge_type: :distance}) do
    amount
  end

  def amount(%Activity{duration: amount}, %Challenge{challenge_type: :time}) do
    amount
  end

  def amount(%Activity{elevation_gain: amount}, %Challenge{challenge_type: :altitude}) do
    amount
  end

  def amount(%Activity{}, %Challenge{}) do
    0.0
  end
end

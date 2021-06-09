defmodule Squeeze.Challenges do
  @moduledoc """
  The Challenges context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo
  alias Squeeze.TimeHelper

  alias Squeeze.Challenges.ScoreUpdater
  alias Squeeze.Challenges.{Challenge, ChallengeActivity, Score}

  def list_current_challenges(%User{} = user) do
    today = TimeHelper.today(user)

    query = from p in Challenge,
      join: s in assoc(p, :scores),
      where: p.end_date >= ^today,
      where: s.user_id == ^user.id,
      preload: [scores: ^five_scores_query()]

    Repo.all(query)
  end

  def list_challenges(%User{} = user, start_date, end_date) do
    start_date = TimeHelper.beginning_of_day(user, start_date)
    end_date = TimeHelper.beginning_of_day(user, end_date)

    query = from p in Challenge,
      join: s in assoc(p, :scores),
      where: p.start_date >= ^start_date,
      where: p.end_date <= ^end_date,
      where: s.user_id == ^user.id,
      preload: [scores: ^five_scores_query()]

    Repo.all(query)
  end

  def list_matched_challenges(%Activity{} = activity) do
    query = from c in Challenge,
      join: s in assoc(c, :scores),
      where: s.user_id == ^activity.user_id,
      where: c.start_date <= ^activity.start_at_local,
      where: c.end_date >= ^activity.start_at_local,
      where: c.activity_type == ^activity.activity_type,
      preload: [scores: ^five_scores_query()]

    Repo.all(query)
  end

  def list_challenges(%User{} = user) do
    query = from p in Challenge,
      join: s in assoc(p, :scores),
      where: s.user_id == ^user.id,
      preload: [scores: ^five_scores_query()]

    Repo.all(query)
  end

  def get_challenge_by_slug!(slug) do
    query = from p in Challenge,
      where: p.slug == ^slug,
      preload: [scores: ^five_scores_query()]

    Repo.one!(query)
  end

  defp five_scores_query do
    ranking_query =
      from c in Score,
      select: %{id: c.id, row_number: row_number() |> over(:challenges_partition)},
      windows: [challenges_partition: [partition_by: :challenge_id, order_by: [desc: :score, asc: :inserted_at]]]

    from c in Score,
      join: r in subquery(ranking_query),
      on: c.id == r.id and r.row_number <= 5,
      order_by: [desc: :score, asc: :inserted_at],
      preload: :user
  end

  def current_leader(%Challenge{} = challenge) do
    query = from u in User,
      join: s in assoc(u, :scores),
      where: s.challenge_id == ^challenge.id,
      order_by: [desc: s.score, asc: s.inserted_at],
      limit: 1

    Repo.one(query)
  end

  def list_users(%Challenge{} = challenge, opts \\ [limit: 100]) do
    query = from u in User,
      join: s in assoc(u, :scores),
      where: s.challenge_id == ^challenge.id,
      limit: ^opts[:limit],
      preload: [:user_prefs]

    Repo.all(query)
  end

  def list_scores(%Challenge{} = challenge, opts \\ [limit: 100]) do
    query = from s in Score,
      where: s.challenge_id == ^challenge.id,
      order_by: [desc: :score, asc: :inserted_at],
      limit: ^opts[:limit],
      preload: [:user]

    Repo.all(query)
  end

  def get_score!(%User{} = user, %Challenge{} = challenge) do
    query = from s in Score,
      where: s.challenge_id == ^challenge.id,
      where: s.user_id == ^user.id

    Repo.one!(query)
  end

  def in_challenge?(%User{} = user, %Challenge{} = challenge) do
    query = from s in Score,
      where: s.challenge_id == ^challenge.id,
      where: s.user_id == ^user.id

    Repo.exists?(query)
  end

  def create_challenge(%User{} = user, attrs \\ %{}) do
    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert_with_slug()
  end

  def add_user_to_challenge(%User{} = user, %Challenge{} = challenge) do
    amount = ScoreUpdater.total_amount(user, challenge)

    %Score{}
    |> Score.changeset()
    |> Changeset.put_assoc(:user, user)
    |> Changeset.put_assoc(:challenge, challenge)
    |> Changeset.put_change(:amount, amount)
    |> Changeset.put_change(:score, ranking_score(challenge, amount))
    |> Repo.insert()
  end

  def list_challenge_activities(%Challenge{} = challenge) do
    query = from a in ChallengeActivity,
      where: a.challenge_id == ^challenge.id,
      order_by: [desc: :inserted_at],
      preload: [activity: :user],
      limit: 50

    Repo.all(query)
  end

  def create_challenge_activity(%Challenge{} = challenge, %Activity{} = activity, attrs \\ %{}) do
    %ChallengeActivity{}
    |> ChallengeActivity.changeset(attrs)
    |> Changeset.put_assoc(:activity, activity)
    |> Changeset.put_assoc(:challenge, challenge)
    |> Repo.insert()
  end

  def update_score!(%Challenge{} = challenge, %Score{} = score, amount) do
    score
    |> Score.changeset()
    |> Changeset.put_change(:amount, amount)
    |> Changeset.put_change(:score, ranking_score(challenge, amount))
    |> Repo.update!()
  end

  def change_challenge(%Challenge{} = challenge) do
    Challenge.changeset(challenge, %{})
  end

  defp ranking_score(%Challenge{challenge_type: :segment}, nil), do: -31622400.0 # default to 1 year
  defp ranking_score(%Challenge{challenge_type: :segment}, amount), do: amount * -1.0
  defp ranking_score(%Challenge{}, amount), do: amount
end

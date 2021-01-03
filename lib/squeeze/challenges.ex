defmodule Squeeze.Challenges do
  @moduledoc """
  The Challenges context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo
  alias Squeeze.SlugGenerator

  alias Squeeze.Challenges.ScoreUpdater
  alias Squeeze.Challenges.{Challenge, Score}

  def list_current_challenges(%User{} = user) do
    end_at = Timex.now

    query = from p in Challenge,
      join: s in assoc(p, :scores),
      where: p.end_at >= ^end_at,
      where: s.user_id == ^user.id,
      preload: [scores: ^five_scores_query()]

    Repo.all(query)
  end

  def list_matched_challenges(%Activity{} = activity) do
    query = from c in Challenge,
      where: c.start_at <= ^activity.start_at,
      where: c.end_at >= ^activity.start_at,
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
      windows: [challenges_partition: [partition_by: :challenge_id, order_by: [desc: :score]]]

    from c in Score,
      join: r in subquery(ranking_query),
      on: c.id == r.id and r.row_number <= 5,
      preload: :user
  end

  def list_scores(%Challenge{} = challenge) do
    query = from s in Score,
      where: s.challenge_id == ^challenge.id,
      order_by: [desc: s.score],
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
    slug = SlugGenerator.gen_slug()

    case Repo.get_by(Challenge, slug: slug) do
      %Challenge{} -> create_challenge(user, attrs) # Try again if a challenge exists with slug
      nil ->
        %Challenge{}
        |> Challenge.changeset(attrs)
        |> Changeset.put_change(:user_id, user.id)
        |> Changeset.put_change(:slug, slug)
        |> Repo.insert()
    end
  end

  def add_user_to_challenge(%User{} = user, %Challenge{} = challenge) do
    amount = ScoreUpdater.total_amount(user, challenge)

    %Score{}
    |> Score.changeset()
    |> Changeset.put_assoc(:user, user)
    |> Changeset.put_assoc(:challenge, challenge)
    |> Changeset.put_change(:score, amount)
    |> Repo.insert()
  end

  def update_score!(%Score{} = score, attrs) do
    score
    |> Score.changeset(attrs)
    |> Repo.update!()
  end

  def change_challenge(%Challenge{} = challenge) do
    Challenge.changeset(challenge, %{})
  end
end

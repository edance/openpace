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
  alias Squeeze.TimeHelper

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

  def list_challenges(%User{} = user, start_date, end_date) do
    start_date = TimeHelper.beginning_of_day(user, start_date)
    end_date = TimeHelper.beginning_of_day(user, end_date)

    query = from p in Challenge,
      join: s in assoc(p, :scores),
      where: p.start_at >= ^start_date,
      where: p.end_at <= ^end_date,
      where: s.user_id == ^user.id,
      preload: [scores: ^five_scores_query()]

    Repo.all(query)
  end

  def list_matched_challenges(%Activity{} = activity) do
    query = from c in Challenge,
      join: s in assoc(c, :scores),
      where: s.user_id == ^activity.user_id,
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
      order_by: [desc: :score],
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
    case insert_challenge(user, attrs) do
      {:error, %Ecto.Changeset{} = changeset} ->
        # try again if the slug has a collision
        if changeset.errors[:slug] do
          insert_challenge(user, attrs)
        else
          {:error, changeset}
        end
      resp -> resp
    end
  end

  defp insert_challenge(%User{} = user, attrs) do
    slug = SlugGenerator.gen_slug()

    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Changeset.put_change(:user_id, user.id)
    |> Changeset.put_change(:slug, slug)
    |> Repo.insert()
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

  defp ranking_score(%Challenge{challenge_type: :segment}, amount), do: amount * -1.0
  defp ranking_score(%Challenge{}, amount), do: amount
end

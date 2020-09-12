defmodule Squeeze.Challenges do
  @moduledoc """
  The Challenges context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Repo

  alias Squeeze.Challenges.{Challenge, Score}

  def list_challenges(%User{} = user) do
    ranking_query =
      from c in Score,
      select: %{id: c.id, row_number: row_number() |> over(:challenges_partition)},
      windows: [challenges_partition: [partition_by: :challenge_id, order_by: :score]]

    scores_query =
      from c in Score,
      join: r in subquery(ranking_query),
      on: c.id == r.id and r.row_number <= 5,
      preload: :user

    query = from p in Challenge,
      join: s in assoc(p, :scores),
      where: s.user_id == ^user.id,
      preload: [scores: ^scores_query]

    Repo.all(query)
  end

  def get_challenge!(%User{} = user, id) do
    Challenge
    |> by_user(user)
    |> Repo.get!(id)
  end

  def create_challenge(%User{} = user, attrs \\ %{}) do
    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  def add_user_to_challenge(%User{} = user, %Challenge{} = challenge) do
    %Score{}
    |> Score.changeset()
    |> Changeset.put_assoc(:user, user)
    |> Changeset.put_assoc(:challenge, challenge)
    |> Repo.insert()
  end

  def change_challenge(%Challenge{} = challenge) do
    Challenge.changeset(challenge, %{})
  end

  defp by_user(query, %User{} = user) do
    from q in query,
      join: u in assoc(q, :users),
      where: u.id == ^user.id
  end
end

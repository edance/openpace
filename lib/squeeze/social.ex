defmodule Squeeze.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias Ecto.{Changeset, Multi}
  alias Squeeze.Accounts.User
  alias Squeeze.Social.Follow
  alias Squeeze.Repo

  @doc """
  Returns the list of follows.

  ## Examples

  iex> list_following(user)
  [%User{}, ...]

  """
  def list_following(%User{} = user) do
    subset =
      from f in Follow,
        where: f.follower_id == ^user.id,
        select: f.followee_id

    query =
      from u in User,
        where: u.id in subquery(subset)

    Repo.all(query)
  end

  @doc """
  Returns the list of follows.

  ## Examples

      iex> list_followers(user)
      [%User{}, ...]

  """
  def list_followers(%User{} = user) do
    subset =
      from f in Follow,
        where: f.followee_id == ^user.id,
        select: f.follower_id

    query =
      from u in User,
        where: u.id in subquery(subset)

    Repo.all(query)
  end

  @doc """
  Follows a user.

  follow_user(Alice, Bob) # Alice follows Bob
  - Create a follow with follower == Alice and followee == Bob
  - Increment Bob's follower_count
  - Increment Alice's following_count

  ## Examples

      iex> follow_user(user1, user2)
      {:ok, %User{}}

  """

  def follow_user(%User{} = follower, %User{} = followee) do
    changeset =
      %Follow{}
      |> Follow.changeset()
      |> Changeset.put_change(:follower_id, follower.id)
      |> Changeset.put_change(:followee_id, followee.id)

    follower_query = from(u in User, where: u.id == ^follower.id)
    followee_query = from(u in User, where: u.id == ^followee.id)

    Multi.new()
    |> Multi.insert(:follow, changeset)
    |> Multi.update_all(:follower_count, followee_query, inc: [follower_count: 1])
    |> Multi.update_all(:following_count, follower_query, inc: [following_count: 1])
    |> Repo.transaction()
  end

  @doc """
  Unfollows a user.

  unfollow_user(Alice, Bob) # Alice unfollows Bob
  - Delete the follow with follower == Alice and followee == Bob
  - Decrement Bob's follower_count
  - Decrement Alice's following_count

  ## Examples

      iex> unfollow_user(user1, user2)
      {:ok, %Follow{}}

  """
  def unfollow_user(%User{} = follower, %User{} = followee) do
    follow_query =
      from f in Follow,
        where: [follower_id: ^follower.id],
        where: [followee_id: ^followee.id]

    follower_query = from(u in User, where: u.id == ^follower.id)
    followee_query = from(u in User, where: u.id == ^followee.id)

    Multi.new()
    |> Multi.delete_all(:follow, follow_query)
    |> Multi.update_all(:follower_count, followee_query, inc: [follower_count: -1])
    |> Multi.update_all(:following_count, follower_query, inc: [following_count: -1])
    |> Repo.transaction()
  end
end

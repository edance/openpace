defmodule Squeeze.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
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
    query = from u in User,
      join: f in Follow, on: u.id == f.follower_id,
      where: f.follower_id == ^user.id

    Repo.all(query)
  end

  @doc """
  Returns the list of follows.

  ## Examples

      iex> list_followers(user)
      [%User{}, ...]

  """
  def list_followers(%User{} = user) do
    query = from u in User,
      join: f in Follow, on: u.id == f.followee_id,
      where: f.followee_id == ^user.id

    Repo.all(query)
  end

  @doc """
  Creates a follow.

  ## Examples

      iex> create_follow(%{field: value})
      {:ok, %Follow{}}

      iex> create_follow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_follow(%User{} = follower, %User{} = followee) do
    %Follow{}
    |> Changeset.put_change(:follower_id, follower.id)
    |> Changeset.put_change(:followee_id, followee.id)
    |> Repo.insert()
  end

  @doc """
  Deletes a follow.

  ## Examples

      iex> delete_follow(follow)
      {:ok, %Follow{}}

      iex> delete_follow(follow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follow(%User{id: id}, user_id) do
    query = from f in Follow,
      where: [user_id: ^id],
      where: [follows_id: ^user_id]

    Repo.delete(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking follow changes.

  ## Examples

      iex> change_follow(follow)
      %Ecto.Changeset{source: %Follow{}}

  """
  def change_follow(%Follow{} = follow) do
    Follow.changeset(follow, %{})
  end
end

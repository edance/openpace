defmodule Squeeze.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Social.Follower
  alias Squeeze.Repo

  @doc """
  Returns the list of followers.

  ## Examples

      iex> list_followers(user_id)
      [%Follower{}, ...]

  """
  def list_followers(user_id) do
    query = from f in Follower,
      where: [user_id: ^user_id],
      preload: :user

    Repo.all(query)
  end

  @doc """
  Creates a follower.

  ## Examples

      iex> create_follower(%{field: value})
      {:ok, %Follower{}}

      iex> create_follower(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_follower(%User{} = user, user_id) do
    %Follower{}
    |> Changeset.put_change(:user_id, user.id)
    |> Changeset.put_change(:follows_id, user_id)
    |> Repo.insert()
  end

  @doc """
  Deletes a follower.

  ## Examples

      iex> delete_follower(follower)
      {:ok, %Follower{}}

      iex> delete_follower(follower)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follower(%User{id: id}, user_id) do
    query = from f in Follower,
      where: [user_id: ^id],
      where: [follows_id: ^user_id]

    Repo.delete(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking follower changes.

  ## Examples

      iex> change_follower(follower)
      %Ecto.Changeset{source: %Follower{}}

  """
  def change_follower(%Follower{} = follower) do
    Follower.changeset(follower, %{})
  end
end

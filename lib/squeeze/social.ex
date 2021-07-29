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

      iex> list_follows(user_id)
      [%Follow{}, ...]

  """
  def list_follows(user_id) do
    query = from f in Follow,
      where: [user_id: ^user_id],
      preload: :user

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
  def create_follow(%User{} = user, user_id) do
    %Follow{}
    |> Changeset.put_change(:user_id, user.id)
    |> Changeset.put_change(:follows_id, user_id)
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

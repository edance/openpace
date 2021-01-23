defmodule Squeeze.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Repo

  alias Squeeze.Notifications.PushToken

  def list_push_tokens(%User{} = user) do
    query = from t in PushToken,
      where: t.user_id == ^user.id

    Repo.all(query)
  end

  @doc """
  Creates a push_token.

  ## Examples

      iex> create_push_token(user, token)
      {:ok, %PushToken{}}

      iex> create_push_token(user, nil)
      {:error, %Ecto.Changeset{}}

  """
  def create_push_token(%User{} = user, token) do
    %PushToken{}
    |> PushToken.changeset(%{token: token})
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Deletes a push_token.

  ## Examples

      iex> delete_push_token(push_token)
      {:ok, %PushToken{}}

      iex> delete_push_token(push_token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_push_token(%PushToken{} = push_token) do
    Repo.delete(push_token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking push_token changes.

  ## Examples

      iex> change_push_token(push_token)
      %Ecto.Changeset{source: %PushToken{}}

  """
  def change_push_token(%PushToken{} = push_token) do
    PushToken.changeset(push_token, %{})
  end
end

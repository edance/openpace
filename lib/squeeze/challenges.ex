defmodule Squeeze.Challenges do
  @moduledoc """
  The Challenges context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Repo

  alias Squeeze.Challenges.Challenge

  def list_challenges(%User{} = user) do
    Challenge
    |> by_user(user)
    |> Repo.all()
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

  def change_challenge(%Challenge{} = challenge) do
    Challenge.changeset(challenge, %{})
  end

  defp by_user(query, %User{} = user) do
    from q in query, where: [user_id: ^user.id]
  end
end

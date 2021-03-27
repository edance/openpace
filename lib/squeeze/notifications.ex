defmodule Squeeze.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Challenges
  alias Squeeze.Challenges.{Challenge, Score}
  alias Squeeze.ExpoNotifications
  alias Squeeze.Repo

  alias Squeeze.Notifications.{PushToken}

  def notify_user_joined(%Challenge{} = challenge, %User{} = user) do
    # Notify everyone if 20 or fewer users in challenge
    if user_count_in_challenge(challenge) <= 20 do
      messages = push_tokens_in_challenge(challenge)
      |> Enum.map(fn (token) ->
        %{
          to: token.token,
          title: "A Challenger Has Joined",
          body: "#{User.full_name(user)} has entered #{challenge.name}!"
        }
      end)

      ExpoNotifications.push_list(messages)
    end
  end

  def notify_leader_change(%Challenge{} = challenge) do
    scores = Challenges.list_scores(challenge, limit: 2)
    lead = List.first(scores)

    # Notify everyone if 10 or fewer users in challenge
    if user_count_in_challenge(challenge) <= 10 do
      messages = push_tokens_in_challenge(challenge)
      |> Enum.map(fn (token) ->
        %{
          to: token.token,
          title: "#{User.full_name(lead.user)} Has Taken the Lead",
          body: "#{User.full_name(lead.user)} has taken the lead in #{challenge.name}",
        }

      end)

      ExpoNotifications.push_list(messages)
    end
  end

  def notify_challenge_started(%Challenge{} = challenge) do
    messages = push_tokens_in_challenge(challenge)
    |> Enum.map(fn (token) ->
      %{
        to: token.token,
        title: "#{challenge.name} Has Started"
      }
    end)

    ExpoNotifications.push_list(messages)
  end

  def notify_challenge_ended(%Challenge{} = challenge) do
    messages = push_tokens_in_challenge(challenge)
    |> Enum.map(fn (token) ->
      %{
        to: token.token,
        title: "#{challenge.name} Has Ended"
      }
    end)

    ExpoNotifications.push_list(messages)
  end

  def notify_challenge_ending(%Challenge{} = challenge) do
    messages = push_tokens_in_challenge(challenge)
    |> Enum.map(fn (token) ->
      %{
        to: token.token,
        title: "#{challenge.name} Is Ending Soon",
      }
    end)

    ExpoNotifications.push_list(messages)
  end

  defp push_tokens_in_challenge(%Challenge{} = challenge)  do
    query = from t in PushToken,
      join: s in Score, on: t.user_id == s.user_id,
      where: s.challenge_id == ^challenge.id,
      preload: [:user]

    Repo.all(query)
  end

  defp user_count_in_challenge(%Challenge{} = challenge) do
    query = from u in User,
      join: s in assoc(u, :scores),
      where: s.challenge_id == ^challenge.id,
      select: count(u.id)

    Repo.one(query)
  end

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

defmodule Squeeze.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Repo

  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Races.{Race, RaceGoal}

  @doc """
  Gets a single race.

  Raises `Ecto.NoResultsError` if the Race does not exist.

  ## Examples

      iex> get_race!("boston-marathon")
      %Race{}

      iex> get_race!("fake-marathon")
      ** (Ecto.NoResultsError)

  """
  def get_race!(slug) do
    Race
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:events, :result_summaries])
  end

  def create_race(attrs \\ %{}) do
    %Race{}
    |> Race.changeset(attrs)
    |> Repo.insert_with_slug()
  end

  def create_race_goal(%User{} = user, attrs \\ %{}) do
    %RaceGoal{}
    |> RaceGoal.changeset(attrs)
    |> Changeset.cast_assoc(:race, with: &Race.changeset/2)
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  def list_race_activities(%User{} = user) do
    query = from a in Activity,
      where: [user_id: ^user.id],
      where: [workout_type: :race],
      order_by: [desc: :start_at]

    Repo.all(query)
  end

  def list_upcoming_race_goals(%User{} = user) do
    query = from r in RaceGoal,
      where: [user_id: ^user.id]

    query
    |> Repo.all()
    |> Repo.preload(:race)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking race changes.

  ## Examples

  iex> change_race(race)
  %Ecto.Changeset{source: %Race{}}

  """
  def change_race_goal(%RaceGoal{} = race_goal) do
    RaceGoal.changeset(race_goal, %{})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking race changes.

  ## Examples

  iex> change_race(race)
  %Ecto.Changeset{source: %Race{}}

  """
  def change_race(%Race{} = race) do
    Race.changeset(race, %{})
  end
end

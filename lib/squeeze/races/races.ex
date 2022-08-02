defmodule Squeeze.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Repo

  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Races.{Race, RaceGoal, TrainingPace}

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

  def get_race_goal!(slug) do
    RaceGoal
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:race])
  end

  def create_race(attrs \\ %{}) do
    %Race{}
    |> Race.changeset(attrs)
    |> Repo.insert_with_slug()
  end

  def create_race_goal(%User{} = user, attrs \\ %{}) do
    changeset = %RaceGoal{}
    |> RaceGoal.changeset(attrs)
    |> Changeset.cast_assoc(:race, with: &Race.changeset/2)
    |> Changeset.put_change(:user_id, user.id)

    changeset
    |> Changeset.put_embed(:training_paces, default_paces(changeset))
    |> Repo.insert_with_slug()
  end

  def list_race_activities(%User{} = user) do
    query = from a in Activity,
      where: [user_id: ^user.id],
      where: [workout_type: :race],
      order_by: [desc: :start_at]

    Repo.all(query)
  end

  def next_race_goal(%User{} = user) do
    query = from rg in RaceGoal,
      join: r in assoc(rg, :race),
      where: [user_id: ^user.id],
      order_by: [asc: r.start_date],
      limit: 1

    query
    |> Repo.one()
    |> Repo.preload(:race)
  end

  def list_upcoming_race_goals(%User{} = user) do
    query = from rg in RaceGoal,
      join: r in assoc(rg, :race),
      where: [user_id: ^user.id],
      order_by: [asc: r.start_date]

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

  defp default_paces(changeset) do
    distance = Changeset.get_change(changeset, :distance)
    duration = Changeset.get_change(changeset, :duration)
    if distance && duration do
      TrainingPace.default_paces(distance, duration)
    else
      []
    end
  end
end

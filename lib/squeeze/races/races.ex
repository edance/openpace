defmodule Squeeze.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  import Squeeze.TimeHelper, only: [today: 1]
  alias Ecto.Changeset
  alias Squeeze.Repo

  alias Squeeze.Accounts.User
  alias Squeeze.Activities.Activity
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
    |> Repo.preload([:training_paces])
    |> Repo.preload(activity: [:trackpoint_set, :laps])
  end

  def create_race(attrs \\ %{}) do
    %Race{}
    |> Race.changeset(attrs)
    |> Repo.insert_with_slug()
  end

  def create_race_goal(%User{} = user, attrs \\ %{}) do
    changeset =
      %RaceGoal{}
      |> RaceGoal.changeset(attrs)
      |> Changeset.put_change(:user_id, user.id)

    changeset
    |> Changeset.put_assoc(:training_paces, default_paces(changeset))
    |> Repo.insert_with_slug()
  end

  def update_race_goal(%RaceGoal{} = race_goal, attrs) do
    race_goal
    |> RaceGoal.changeset(attrs)
    |> Repo.update()
  end

  def find_or_create_race_goal_from_activity(activity) do
    date = Timex.to_date(activity.start_at_local)
    race_goal = Repo.get_by(RaceGoal, user_id: activity.user_id, race_date: date)

    if race_goal do
      {:ok, race_goal}
    else
      create_race_goal_from_activity(activity)
    end
  end

  def create_race_goal_from_activity(activity) do
    attrs = %{
      race_name: activity.name,
      race_date: activity.start_at_local,
      duration: activity.duration,
      distance: activity.distance
    }

    changeset =
      %RaceGoal{}
      |> RaceGoal.changeset(attrs)
      |> Changeset.put_change(:user_id, activity.user_id)
      |> Changeset.put_change(:activity_id, activity.id)

    changeset
    |> Changeset.put_assoc(:training_paces, default_paces(changeset))
    |> Repo.insert_with_slug()
  end

  def list_race_activities(%User{} = user) do
    query =
      from a in Activity,
        where: [user_id: ^user.id],
        where: [workout_type: :race],
        order_by: [desc: :start_at]

    Repo.all(query)
  end

  def list_previous_race_goals(%User{} = user) do
    query =
      from rg in RaceGoal,
        where: rg.race_date <= ^today(user),
        where: rg.user_id == ^user.id,
        order_by: [desc: rg.race_date]

    query
    |> Repo.all()
    |> Repo.preload([:race, :activity])
  end

  def next_race_goal(%User{} = user) do
    query =
      from rg in RaceGoal,
        where: [user_id: ^user.id],
        order_by: [asc: rg.race_date],
        limit: 1

    query
    |> Repo.one()
    |> Repo.preload(:race)
  end

  def nearest_race_goal(%User{} = user, date \\ nil) do
    date = date || today(user)

    # First attempt to get future goals
    future_goals_query =
      from rg in RaceGoal,
        where: rg.race_date >= ^date,
        where: rg.user_id == ^user.id,
        order_by: [asc: rg.race_date],
        limit: 1

    # Fallback query for past goals
    past_goals_query =
      from rg in RaceGoal,
        where: rg.race_date < ^date,
        where: rg.user_id == ^user.id,
        order_by: [desc: rg.race_date],
        limit: 1

    from(
      rg in subquery(
        from(r in subquery(future_goals_query),
          union_all: ^past_goals_query
        )
      ),
      limit: 1
    )
    |> Repo.one()
  end

  def list_upcoming_race_goals(%User{} = user) do
    query =
      from rg in RaceGoal,
        where: rg.race_date >= ^today(user),
        where: rg.user_id == ^user.id,
        order_by: [asc: rg.race_date]

    query
    |> Repo.all()
    |> Repo.preload(:race)
  end

  def list_race_goals(%User{} = user) do
    query =
      from rg in RaceGoal,
        where: rg.user_id == ^user.id,
        order_by: [asc: rg.race_date]

    Repo.all(query)
  end

  def list_race_goals(%User{} = user, %{first: first, last: last}) do
    query =
      from rg in RaceGoal,
        where: rg.race_date >= ^first,
        where: rg.race_date <= ^last,
        where: rg.user_id == ^user.id,
        order_by: [asc: rg.race_date]

    query
    |> Repo.all()
  end

  @doc """
  Deletes an RaceGoal.

  ## Examples

  iex> delete_race_goal(race_goal)
  {:ok, %RaceGoal{}}

  iex> delete_race_goal(race_goal)
  {:error, %Ecto.Changeset{}}

  """
  def delete_race_goal(%RaceGoal{} = race_goal) do
    Repo.delete(race_goal)
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

  def create_training_pace(%RaceGoal{} = race_goal, attrs) do
    %TrainingPace{}
    |> TrainingPace.changeset(attrs)
    |> Changeset.put_change(:race_goal_id, race_goal.id)
    |> Repo.insert()
  end

  def create_default_paces(%RaceGoal{} = race_goal) do
    paces = TrainingPace.default_paces(race_goal)

    race_goal
    |> RaceGoal.changeset(%{})
    |> Changeset.put_assoc(:training_paces, paces)
    |> Repo.update()
  end

  defp default_paces(changeset) do
    distance = Changeset.get_change(changeset, :distance)
    duration = Changeset.get_change(changeset, :duration)

    if distance && duration do
      TrainingPace.default_paces(%{distance: distance, duration: duration})
    else
      []
    end
  end
end

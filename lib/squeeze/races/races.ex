defmodule Squeeze.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  import Squeeze.TimeHelper, only: [today: 1]
  alias Ecto.Changeset
  alias Squeeze.Repo

  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, TrackpointSection}
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
      where: r.start_date >= ^today(user),
      where: rg.user_id == ^user.id,
      order_by: [asc: r.start_date]

    query
    |> Repo.all()
    |> Repo.preload(:race)
  end

  def list_race_goals(%User{} = user, %{first: first, last: last}) do
    query = from rg in RaceGoal,
      join: r in assoc(rg, :race),
      where: r.start_date >= ^first,
      where: r.start_date <= ^last,
      where: rg.user_id == ^user.id,
      order_by: [asc: r.start_date]

    query
    |> Repo.all()
    |> Repo.preload(:race)
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

  # SELECT CASE WHEN velocity < 2 THEN '< 2'
  # WHEN velocity BETWEEN 2 AND 3 THEN '2-3'
  # WHEN velocity BETWEEN 3 AND 4 THEN '3-4'
  # WHEN velocity > 4 THEN '> 4'
  # END,
  # SUM(duration) as duration
  # FROM trackpoint_sections
  # GROUP BY 1;
  def duration_by_pace(user, date_range, training_paces) do
    start_at = Timex.beginning_of_day(date_range.first) |> Timex.to_datetime()
    end_at = Timex.end_of_day(date_range.last) |> Timex.to_datetime()
    [p1, p2, p3, p4, p5, p6] = training_paces

    from(tps in TrackpointSection)
    |> join(:inner, [tps], a in assoc(tps, :activity))
    |> where([_tps, a], a.user_id == ^user.id and a.type == "Run")
    |> where([_tps, a], a.start_at_local >= ^start_at and a.start_at_local <= ^end_at)
    |> group_by(fragment("1"))
    |> select([tps],
    [
      fragment(
        """
        CASE
        WHEN ? BETWEEN ? AND ? THEN ?
        WHEN ? BETWEEN ? AND ? THEN ?
        WHEN ? BETWEEN ? AND ? THEN ?
        WHEN ? BETWEEN ? AND ? THEN ?
        WHEN ? BETWEEN ? AND ? THEN ?
        WHEN ? BETWEEN ? AND ? THEN ?
        END
        """,
        tps.velocity, ^min_speed(p1), ^max_speed(p1), ^p1.name,
        tps.velocity, ^min_speed(p2), ^max_speed(p2), ^p2.name,
        tps.velocity, ^min_speed(p3), ^max_speed(p3), ^p3.name,
        tps.velocity, ^min_speed(p4), ^max_speed(p4), ^p4.name,
        tps.velocity, ^min_speed(p5), ^max_speed(p5), ^p5.name,
        tps.velocity, ^min_speed(p6), ^max_speed(p6), ^p6.name
      ),
      sum(tps.duration)
    ])
    |> Repo.all()
  end

  defp min_speed(pace) do
    pace.min_speed || TrainingPace.adjust_pace_by_secs(pace.speed, 10)
  end

  defp max_speed(pace) do
    pace.max_speed || TrainingPace.adjust_pace_by_secs(pace.speed, -10)
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

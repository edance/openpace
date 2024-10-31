defmodule Squeeze.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  import Squeeze.TimeHelper, only: [today: 1]
  alias Ecto.Changeset
  alias Squeeze.Repo

  alias Squeeze.Accounts.User
  alias Squeeze.Activities.{Activity, TrackpointSection}
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
    |> Changeset.put_embed(:training_paces, default_paces(changeset))
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

  def list_race_goals(%User{} = user, %{first: first, last: last}) do
    query =
      from rg in RaceGoal,
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

  def pace_durations_for_race_goal(%RaceGoal{} = goal) do
    date_range = block_range(goal)
    start_at = Timex.beginning_of_day(date_range.first) |> Timex.to_datetime()
    end_at = Timex.end_of_day(date_range.last) |> Timex.to_datetime()

    filtered_activities =
      from(a in Activity,
        where:
          a.user_id == ^goal.user_id and
            a.start_at_local >= ^start_at and
            a.start_at_local <= ^end_at and
            a.status == :complete and
            a.type == "Run",
        select: a.id
      )

    filtered_trackpoints =
      from(ts in TrackpointSection,
        join: fa in subquery(filtered_activities),
        on: ts.activity_id == fa.id
      )

    from(tp in TrainingPace,
      left_join: ts in subquery(filtered_trackpoints),
      on:
        ts.velocity >= tp.min_speed and
          ts.velocity <= tp.max_speed,
      where: tp.race_goal_id == ^goal.id,
      group_by: [tp.id],
      order_by: tp.min_speed,
      select: %{
        id: tp.id,
        pace_name: min(tp.name),
        pace_color: min(tp.color),
        min_speed: min(tp.min_speed),
        max_speed: min(tp.max_speed),
        total_distance: coalesce(sum(ts.distance), 0),
        total_duration: coalesce(sum(ts.duration), 0),
        activity_count: count(fragment("DISTINCT ?", ts.activity_id))
      }
    )
    |> Repo.all()
  end

  def block_range(%RaceGoal{} = race_goal) do
    race_date = race_goal.race_date

    # 18 weeks before minus 1 day
    start_date = Timex.shift(race_date, days: 18 * -7 + 1)

    case Date.day_of_week(start_date) do
      1 -> Date.range(start_date, race_date)
      x -> Date.range(Date.add(start_date, -(x - 1)), race_date)
    end
  end

  defp default_paces(changeset) do
    distance = Changeset.get_change(changeset, :distance)
    duration = Changeset.get_change(changeset, :duration)
    require IEx
    IEx.pry()

    if distance && duration do
      TrainingPace.default_paces(distance, duration)
    else
      []
    end
  end
end

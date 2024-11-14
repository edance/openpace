defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.User
  alias Squeeze.Activities.{Activity, TrackpointSection}
  alias Squeeze.Races.{RaceGoal, TrainingPace}
  alias Squeeze.Repo
  alias Squeeze.TimeHelper

  def ytd_run_summary(%User{} = user) do
    time_window =
      Timex.now()
      |> Timex.beginning_of_year()
      |> Timex.to_naive_datetime()

    query =
      from a in Activity,
        where: a.status == :complete,
        where: a.start_at_local > ^time_window,
        where: a.user_id == ^user.id,
        where: a.type == "Run",
        select: %{
          distance: fragment("coalesce(?, 0)", sum(a.distance)),
          duration: fragment("coalesce(?, 0)", sum(a.duration)),
          elevation_gain: fragment("coalesce(?, 0)", sum(a.elevation_gain)),
          count: count(a.id)
        }

    Repo.one(query)
  end

  def monthly_summary(%User{} = user) do
    time_window =
      Timex.now()
      |> Timex.beginning_of_year()
      |> Timex.to_naive_datetime()

    query =
      from a in Activity,
        where: a.status == :complete,
        where: a.start_at_local > ^time_window,
        where: [user_id: ^user.id],
        group_by: [a.type, fragment("date_trunc('month', ?)", a.start_at_local)],
        select: %{
          distance: sum(a.distance),
          duration: sum(a.duration),
          elevation_gain: sum(a.elevation_gain),
          type: a.type,
          month: fragment("date_trunc('month', ?)", a.start_at_local)
        }

    Repo.all(query)
  end

  @doc """
  Returns a list of active years in order

  ## Examples

  ```elixir
  iex> years_active(user)
  [2017, 2018, 2019, 2020]
  ```
  """
  def years_active(%User{} = user) do
    query =
      from a in Activity,
        where: a.status == :complete,
        where: [user_id: ^user.id],
        group_by: [fragment("date_part('year', ?)", a.start_at_local)],
        order_by: [fragment("date_part('year', ?)", a.start_at_local)],
        select: %{
          year: fragment("cast(date_part('year', ?) as text)", a.start_at_local)
        }

    Repo.all(query)
    |> Enum.map(& &1.year)
  end

  @doc """
  Returns a number for the current activity streak for a user.
  """
  def current_activity_streak(%User{} = user) do
    dates = active_dates(user)
    today = TimeHelper.today(user)
    yesterday = Timex.shift(today, days: -1)
    most_recent_date = List.first(dates)

    if today == most_recent_date || yesterday == most_recent_date do
      dates
      |> Enum.with_index()
      |> Enum.reduce_while(0, fn {x, idx}, acc ->
        if x == Timex.shift(most_recent_date, days: -idx),
          do: {:cont, acc + 1},
          else: {:halt, acc}
      end)
    else
      0
    end
  end

  def pace_bands_for_activity(%Activity{} = activity, %RaceGoal{} = goal) do
    filtered_trackpoints =
      from(ts in TrackpointSection,
        where: ts.activity_id == ^activity.id
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

  def pace_bands_for_race_goal(%RaceGoal{} = goal) do
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

  defp active_dates(%User{} = user) do
    query =
      from a in Activity,
        where: [user_id: ^user.id],
        select: type(a.start_at_local, :date),
        group_by: [type(a.start_at_local, :date)],
        order_by: [desc: type(a.start_at_local, :date)]

    Repo.all(query)
  end
end

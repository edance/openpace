defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.User
  alias Squeeze.Activities.{Activity, TrackpointSection}
  alias Squeeze.Races.TrainingPace
  alias Squeeze.Repo
  alias Squeeze.TimeHelper

  def data_for_training_pace(%User{} = user, %TrainingPace{} = pace, date_range) do
    start_at = Timex.beginning_of_day(date_range.first) |> Timex.to_datetime()
    end_at = Timex.end_of_day(date_range.last) |> Timex.to_datetime()

    query =
      from ts in TrackpointSection,
        join: a in assoc(ts, :activity),
        where: a.status == :complete,
        where: a.user_id == ^user.id,
        where: a.type == "Run",
        where: a.start_at_local >= ^start_at and a.start_at_local <= ^end_at,
        where: ts.velocity >= ^pace.min_speed and ts.velocity < ^pace.max_speed,
        select: %{
          distance: fragment("coalesce(?, 0)", sum(ts.distance)),
          duration: fragment("coalesce(?, 0)", sum(ts.duration))
        }

    Repo.one(query)
  end

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

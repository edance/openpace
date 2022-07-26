defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo
  alias Squeeze.TimeHelper

  def ytd_run_summary(%User{} = user) do
    time_window = Timex.now()
    |> Timex.beginning_of_year()
    |> Timex.to_naive_datetime()

    query = from a in Activity,
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
    time_window = Timex.now()
    |> Timex.beginning_of_year()
    |> Timex.to_naive_datetime()

    query = from a in Activity,
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
  Returns a number for the current activity streak for a user.
  """
  def current_activity_streak(%User{} = user) do
    dates = active_dates(user)
    today = TimeHelper.today(user)
    yesterday = Timex.shift(today, days: -1)
    most_recent_date = List.first(dates)

    if today == most_recent_date || yesterday == most_recent_date do
      streak = dates
      |> Enum.with_index()
      |> Enum.reduce_while(0, fn({x, idx}, acc) ->
        if x == Timex.shift(most_recent_date, days: -idx), do: {:cont, acc + 1}, else: {:halt, acc}
      end)
    else
      0
    end
  end

  defp active_dates(%User{} = user) do
    query = from a in Activity,
      where: [user_id: ^user.id],
      select: type(a.start_at_local, :date),
      group_by: [type(a.start_at_local, :date)],
      order_by: [desc: type(a.start_at_local, :date)]

    Repo.all(query)
  end
end

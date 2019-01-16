defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Distances
  alias Squeeze.TimeHelper

  def dataset_for_year_chart(%User{} = user) do
    dates = yearly_dateset(user)
    map = user
    |> fetch_activities(dates)
    |> Enum.reduce(%{}, fn(x, acc) ->
      date = Timex.beginning_of_week(x.date)
      value = Map.get(acc, date, 0)
      Map.put(acc, date, value + x.distance)
    end)

    dates
    |> Enum.map(&(%{date: &1, distance: map[&1] || 0}))
  end

  def dataset_for_week_chart(%User{} = user) do
    dates = weekly_dateset(user)
    map = user
    |> fetch_activities(dates)
    |> Enum.reduce(%{}, fn(x, acc) ->
      value = Map.get(acc, x.date, 0)
      Map.put(acc, x.date, value + x.distance)
    end)

    dates
    |> Enum.map(&(%{date: &1, distance: map[&1] || 0}))
  end

  def weekly_dateset(user) do
    today = TimeHelper.today(user)
    range = Date.range(Timex.beginning_of_week(today), Timex.end_of_week(today))
    Enum.to_list(range)
  end

  def yearly_dateset(user) do
    date = user
    |> TimeHelper.today()
    |> Timex.beginning_of_week()
    0..30
    |> Enum.map(&Timex.shift(date, weeks: -&1))
    |> Enum.reverse()
  end

  defp fetch_activities(user, dates) do
    today = TimeHelper.today(user)
    range = Date.range(List.first(dates), today)
    user
    |> Dashboard.list_activities(range)
    |> Enum.filter(&(&1.status == :complete))
    |> Enum.map(&map_activity(&1, user))
  end

  defp map_activity(%Activity{distance: distance, start_at: start_at}, user) do
    opts = [imperial: user.user_prefs.imperial]
    %{
      distance: Distances.to_float(distance, opts),
      date: TimeHelper.to_date(user, start_at)
    }
  end
end

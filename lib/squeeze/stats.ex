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
    |> Enum.map(&(%{date: &1, distance: round_distance(map[&1])}))
  end

  def yearly_dateset(user) do
    date = user
    |> TimeHelper.today()
    |> Timex.beginning_of_week()
    0..51
    |> Enum.map(&Timex.shift(date, weeks: -&1))
    |> Enum.reverse()
  end

  defp fetch_activities(user, dates) do
    today = TimeHelper.today(user)
    range = Date.range(List.first(dates), today)
    user
    |> Dashboard.list_activities(range)
    |> Enum.filter(&(String.contains?(&1.type, "Run")))
    |> Enum.filter(&(&1.status == :complete))
    |> Enum.map(&map_activity(&1, user))
  end

  defp map_activity(%Activity{distance: distance} = activity, user) do
    opts = [imperial: user.user_prefs.imperial]
    %{
      distance: Distances.to_float(distance, opts),
      date: date(activity, user)
    }
  end

  defp date(%Activity{start_at: nil, planned_date: date}, _), do: date
  defp date(%Activity{start_at: start_at}, user) do
    TimeHelper.to_date(user, start_at)
  end

  defp round_distance(nil), do: 0.0
  defp round_distance(distance), do: Float.round(distance, 2)
end

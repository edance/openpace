defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Distances
  alias Squeeze.Repo

  def dataset_for_year_chart(%User{user_prefs: %{imperial: imperial}} = user) do
    user
    |> distance_by_week()
    |> Enum.map(&format_distance(&1, imperial: imperial))
    |> Enum.map(&format_label(&1))
  end

  def dataset_for_week_chart(%User{user_prefs: %{imperial: imperial}} = user) do
    user
    |> distance_by_day()
    |> Enum.map(&format_distance(&1, imperial: imperial))
    |> Enum.map(&format_label(&1))
  end

  defp distance_by_week(%User{} = user) do
    query = from a in Activity,
      right_join: weeks in fragment("select generate_series(date_trunc('week', now() - '1 year'::interval), date_trunc('week', now()), '1 week'::interval) as week"),
      on: a.user_id == ^user.id and weeks.week == fragment("date_trunc('week', ?)", a.start_at),
      group_by: weeks.week,
      order_by: weeks.week,
      select: %{
        date: type(weeks.week, :date),
        distance: sum(fragment("coalesce(?, 0)", a.distance))
      }
    Repo.all(query)
  end

  defp distance_by_day(%User{} = user) do
    query = from a in Activity,
      right_join: days in fragment("select generate_series(date_trunc('week', now()), date_trunc('week', now()) + '6 days'::interval, '1 day'::interval) as day"),
      on: a.user_id == ^user.id and days.day == fragment("date_trunc('day', ?)", a.start_at),
      group_by: days.day,
      order_by: days.day,
      select: %{
        date: type(days.day, :date),
        distance: sum(fragment("coalesce(?, 0)", a.distance))
      }
    Repo.all(query)
  end

  defp format_distance(%{distance: distance} = item, opts) do
    Map.merge(item, %{
      distance: Distances.to_float(distance, opts),
      formatted_distance: Distances.format(distance, opts)
    })
  end

  defp format_label(item) do
    Map.merge(item, %{label: Timex.format!(item.date, "%b %-d", :strftime)})
  end
end

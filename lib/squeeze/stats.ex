defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo

  def distance_by_week(%User{} = user) do
    query = from a in Activity,
      right_join: weeks in fragment("select generate_series(date_trunc('week', now() - '1 year'::interval), date_trunc('week', now()), '1 week'::interval) as week"),
      on: a.user_id == ^user.id and weeks.week == fragment("date_trunc('week', ?)", a.start_at),
      group_by: weeks.week,
      order_by: weeks.week,
      select: %{
        date: type(weeks.week, :date),
        sum: sum(fragment("coalesce(?, 0)", a.distance))
      }
    Repo.all(query)
  end

  def distance_by_day(%User{} = user) do
    query = from a in Activity,
      right_join: days in fragment("select generate_series(date_trunc('week', now()), date_trunc('week', now()) + '6 days'::interval, '1 day'::interval) as day"),
      on: a.user_id == ^user.id and days.day == fragment("date_trunc('day', ?)", a.start_at),
      group_by: days.day,
      order_by: days.day,
      select: %{
        date: type(days.day, :date),
        sum: sum(fragment("coalesce(?, 0)", a.distance))
      }
    Repo.all(query)
  end
end

defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo

  def distance_by_month(%User{} = user) do
    query = from a in Activity,
      right_join: months in fragment("select generate_series(date_trunc('month', now()) - '1 year'::interval, date_trunc('month', now()), '1 month'::interval) as month"),
      on: a.user_id == ^user.id and months.month == fragment("date_trunc('month', ?)", a.start_at),
      group_by: months.month,
      order_by: months.month,
      select: %{
        date: type(months.month, :date),
        sum: sum(fragment("coalesce(?, 0)", a.distance))
      }
    Repo.all(query)
  end

  def distance_by_day(%User{} = user) do
    query = from a in Activity,
      right_join: days in fragment("select generate_series(date_trunc('day', now()) - '1 month'::interval, date_trunc('day', now()), '1 day'::interval) as day"),
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

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
      where: [user_id: ^user.id],
      group_by: fragment("date"),
      select: [fragment("date_trunc('month', ?) as date", a.start_at), sum(a.distance)]
    Repo.all(query)
  end

  def distance_by_day(%User{} = user) do
    query = from a in Activity,
      where: [user_id: ^user.id],
      group_by: fragment("date"),
      select: [fragment("date_trunc('day', ?) as date", a.start_at), sum(a.distance)]
    Repo.all(query)
  end
end

defmodule Squeeze.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo

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
        distance: sum(a.distance),
        duration: sum(a.duration),
        elevation_gain: sum(a.elevation_gain),
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
end

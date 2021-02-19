defmodule Mix.Tasks.UpdateStartDates do
  use Mix.Task

  @moduledoc """
  Migrate start_at to start_date
  """

  alias Squeeze.Challenges.Challenge
  alias Squeeze.Repo

  @doc false
  def run(_) do
    Mix.Task.run("app.start")
    # Add start date to all existing challenges
    Repo.all(Challenge)
    |> Enum.map(fn c -> Challenge.changeset(c, %{start_date: Timex.to_date(c.start_at), end_date: Timex.to_date(c.end_at)}) end)
    |> Enum.map(fn c -> Repo.update!(c) end)
  end
end

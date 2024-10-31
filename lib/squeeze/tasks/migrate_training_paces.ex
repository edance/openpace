defmodule Squeeze.Tasks.MigrateTrainingPaces do
  @moduledoc """
    Create default training paces for all existing race goals. Putting this in a task without mix as it is not available on production.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Races
  alias Squeeze.Races.RaceGoal
  alias Squeeze.Repo

  @doc """
    Run the migration task
  """
  def run do
    from(rg in RaceGoal,
      where: not is_nil(rg.duration),
      preload: [:training_paces]
    )
    |> Repo.all()
    |> Enum.each(&migrate_training_paces/1)
  end

  defp migrate_training_paces(%RaceGoal{} = goal) do
    if goal.training_paces == [] do
      Races.create_default_paces(goal)
    end
  end
end

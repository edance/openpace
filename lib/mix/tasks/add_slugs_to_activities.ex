defmodule Mix.Tasks.AddSlugsToActivities do
  use Mix.Task
  @moduledoc false

  alias Squeeze.Activities.Activity
  alias Squeeze.Repo

  @doc false
  def run(_) do
    Mix.Task.run("app.start")

    Repo.all(Activity)
    |> Enum.map(&Activity.changeset/1)
    |> Enum.map(&Repo.add_slug_to_existing/1)
  end
end

defmodule Mix.Tasks.CreateTrackpointSections do
  use Mix.Task
  @moduledoc false

  import Ecto.Query, warn: false
  alias Squeeze.Activities
  alias Squeeze.Activities.TrackpointSet
  alias Squeeze.Repo

  @doc false
  def run(_) do
    Mix.Task.run("app.start")

    # Find all activities in batches
    query = from(t in TrackpointSet)

    stream = Repo.stream(query, max_rows: 10)

    Repo.transaction(fn ->
      stream
      |> Stream.map(&Activities.create_trackpoint_sections/1)
      |> Stream.run()
    end)
  end
end

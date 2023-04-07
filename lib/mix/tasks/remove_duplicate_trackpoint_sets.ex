defmodule Mix.Tasks.RemoveDuplicateTrackpointSets do
  use Mix.Task
  @moduledoc false

  import Ecto.Query, warn: false
  alias Squeeze.Activities.TrackpointSet
  alias Squeeze.Repo

  @doc false
  def run(_) do
    Mix.Task.run("app.start")

    subquery = from ts in TrackpointSet,
      select: %{id: ts.id, row_number: row_number() |> over(:partition)},
      windows: [partition: [partition_by: :activity_id, order_by: :id]]

    query = from ts in TrackpointSet,
      join: s in subquery(subquery),
      on: ts.id == s.id and s.row_number > 1,
      select: ts.id

    Repo.all(query)
    |> Enum.chunk_every(1000)
    |> Enum.map(fn chunk ->
      Repo.delete_all(from ts in TrackpointSet, where: ts.id in ^chunk)
    end)
  end
end

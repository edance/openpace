defmodule Squeeze.Tasks.CreateTrackpointSections do
  @moduledoc """
  Task module for batch processing TrackpointSets to create trackpoint sections.
  This module is designed to process existing TrackpointSets and generate corresponding
  trackpoint sections in batches of 100 records at a time.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Activities
  alias Squeeze.Activities.TrackpointSet
  alias Squeeze.Repo

  @doc """
  Starts the batch processing of all TrackpointSets.

  Returns `{:ok}` when all records have been processed.

  ## Example

      iex> CreateTrackpointSections.run()
      {:ok}
  """
  def run do
    query = from(t in TrackpointSet)
    process_in_batches(query)
  end

  defp process_in_batches(query, page \\ 0) do
    sets =
      query
      |> limit(100)
      |> offset(^page * 100)
      |> Repo.all()

    if sets == [] do
      {:ok}
    else
      sets
      |> Enum.each(&Activities.create_trackpoint_sections/1)

      process_in_batches(query, page + 1)
    end
  end
end

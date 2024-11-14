defmodule Squeeze.Tasks.CreateTrackpointSections do
  @moduledoc """
  Task module for batch processing TrackpointSets to create trackpoint sections.
  This module is designed to process existing TrackpointSets and generate corresponding
  trackpoint sections in batches of 100 records at a time.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Activities
  alias Squeeze.Activities.{TrackpointSection, TrackpointSet}
  alias Squeeze.Repo

  require Logger

  @doc """
  Starts the batch processing of all TrackpointSets.

  Returns `{:ok}` when all records have been processed.

  ## Example

      iex> CreateTrackpointSections.run()
      {:ok}
  """
  def run do
    query =
      from t in TrackpointSet,
        left_join: s in TrackpointSection,
        on: t.activity_id == s.activity_id,
        where: is_nil(s.id)

    total_count = Repo.aggregate(query, :count, :id)

    Logger.info("Processing #{total_count} TrackpointSets to create TrackpointSections")

    result = process_in_batches(query, total_count)
    System.stop(0)
    result
  end

  defp process_in_batches(query, total_count, page \\ 0, processed_count \\ 0) do
    sets =
      query
      |> limit(100)
      |> offset(^page * 100)
      |> Repo.all()

    if sets == [] do
      Logger.info("Completed processing of TrackpointSets to create TrackpointSections")
      {:ok}
    else
      new_processed_count = processed_count + length(sets)

      Logger.info(
        "Processing batch #{page + 1} - #{round(new_processed_count / total_count * 100)}%"
      )

      sets
      |> Enum.each(&Activities.create_trackpoint_sections/1)

      process_in_batches(query, total_count, page + 1, new_processed_count)
    end
  end
end

defmodule Squeeze.Tasks.CreateTrackpointSections do
  @moduledoc """
  Task module for batch processing TrackpointSets to create trackpoint sections.
  This module is designed to process existing TrackpointSets and generate corresponding
  trackpoint sections in batches.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Activities
  alias Squeeze.Activities.{TrackpointSection, TrackpointSet}
  alias Squeeze.Repo

  require Logger

  @default_batch_size 100

  @doc """
  Starts the batch processing of all TrackpointSets.

  ## Options
    * `:batch_size` - The number of records to process in each batch. Defaults to #{@default_batch_size}

  Returns `{:ok}` when all records have been processed.

  ## Examples
      iex> CreateTrackpointSections.run()
      {:ok}

      iex> CreateTrackpointSections.run(batch_size: 50)
      {:ok}
  """
  def run(opts \\ []) do
    batch_size = Keyword.get(opts, :batch_size, @default_batch_size)

    query =
      from t in TrackpointSet,
        left_join: s in TrackpointSection,
        on: t.activity_id == s.activity_id,
        where: is_nil(s.id)

    total_count = Repo.aggregate(query, :count, :id)

    Logger.info("Processing #{total_count} TrackpointSets to create TrackpointSections")

    result = process_in_batches(query, total_count, batch_size)
    System.stop(0)
    result
  end

  defp process_in_batches(query, total_count, batch_size, page \\ 0, processed_count \\ 0) do
    sets =
      query
      |> limit(^batch_size)
      |> offset(^(page * batch_size))
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

      process_in_batches(query, total_count, batch_size, page + 1, new_processed_count)
    end
  end
end

defmodule Squeeze.Tasks.CreateRaceGoals do
  @moduledoc """
  A task to create race goals from existing activities marked as races.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Activities.Activity
  alias Squeeze.Races
  alias Squeeze.Repo

  require Logger

  @default_batch_size 100

  @doc """
  Run the task to create race goals from race activities

  ## Options
    * `:batch_size` - The number of records to process in each batch. Defaults to #{@default_batch_size}

  ## Examples
      iex> CreateRaceGoals.run(batch_size: 50)
  """
  def run(opts \\ []) do
    batch_size = Keyword.get(opts, :batch_size, @default_batch_size)

    Stream.unfold(0, &process_batch(&1, batch_size))
    |> Stream.take_while(&(&1 != nil))
    |> Stream.run()
  end

  defp process_batch(offset, batch_size) do
    activities = get_race_activities(offset, batch_size)

    case activities do
      [] ->
        nil

      activities ->
        process_activities(activities)
        {length(activities), offset + batch_size}
    end
  end

  defp get_race_activities(offset, batch_size) do
    Activity
    |> where([a], a.workout_type == :race and not is_nil(a.start_at_local))
    |> limit(^batch_size)
    |> offset(^offset)
    |> order_by([a], a.id)
    |> Repo.all()
  end

  defp process_activities(activities) do
    Enum.each(activities, fn activity ->
      case Races.find_or_create_race_goal_from_activity(activity) do
        {:ok, _race_goal} ->
          Logger.info("Created race goal for activity: #{activity.name} (ID: #{activity.id})")

        {:error, reason} ->
          Logger.info(
            "Failed to create race goal for activity: #{activity.id}, reason: #{inspect(reason)}"
          )
      end
    end)
  end
end

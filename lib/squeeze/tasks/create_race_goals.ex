defmodule Squeeze.Tasks.CreateRaceGoals do
  @moduledoc """
  A task to create race goals from existing activities marked as races.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Repo
  alias Squeeze.Activities.Activity
  alias Squeeze.Races

  require Logger

  @batch_size 100

  @doc """
  Run the task to create race goals from race activities
  """
  def run do
    Stream.unfold(0, &process_batch/1)
    |> Stream.take_while(&(&1 != nil))
    |> Stream.run()
  end

  defp process_batch(offset) do
    activities = get_race_activities(offset)

    case activities do
      [] ->
        nil

      activities ->
        process_activities(activities)
        {length(activities), offset + @batch_size}
    end
  end

  defp get_race_activities(offset) do
    Activity
    |> where([a], a.workout_type == :race)
    |> limit(@batch_size)
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

defmodule Squeeze.Fitbit.ActivityLoader do
  @moduledoc false

  alias Squeeze.Activities
  alias Squeeze.Accounts.Credential
  alias Squeeze.ActivityMatcher

  def update_or_create_activity(%Credential{} = credential, fitbit_activity) do
    user = credential.user
    activity = map_activity(fitbit_activity)

    case ActivityMatcher.get_closest_activity(user, activity) do
      nil ->
        Activities.create_activity(user, activity)

      existing_activity ->
        activity = %{activity | name: existing_activity.name}
        Activities.update_activity(existing_activity, activity)
    end
  end

  defp map_activity(%{"activityName" => name, "logId" => id} = activity) do
    %{
      name: name,
      type: name,
      distance: distance(activity),
      duration: duration(activity),
      start_at: start_at(activity),
      external_id: "#{id}"
    }
  end

  defp start_at(%{"startTime" => start_time}) do
    case Timex.parse(start_time, "{ISO:Extended:Z}") do
      {:ok, t} -> t
      _ -> nil
    end
  end

  def distance(%{"distance" => distance, "distanceUnit" => unit}) do
    case unit do
      "Kilometer" -> distance * 1000.0
      _ -> distance
    end
  end

  def distance(_), do: 0

  def duration(%{"duration" => duration}), do: trunc(duration / 1000)
  def duration(_), do: 0
end

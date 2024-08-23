defmodule Squeeze.Namer.ActivityRenamer do
  @moduledoc """
  This module renames activities
  """
  require Logger

  alias Squeeze.Namer.DescriptionGenerator
  alias Squeeze.Namer.NameGenerator
  alias Squeeze.Strava.Activities
  alias Strava.DetailedActivity

  def rename(user, activity_id) when is_binary(activity_id) or is_integer(activity_id) do
    case Activities.get_activity_by_id(user, activity_id) do
      {:ok, activity} -> rename(user, activity)
      error -> error
    end
  end

  def rename(_, %DetailedActivity{manual: true} = activity), do: activity

  def rename(user, %DetailedActivity{device_name: device_name} = activity) do
    # Skip all Strava Apps
    if device_name && device_name =~ "Strava" do
      activity
    else
      rename_activity(user, activity)
    end
  end

  defp rename_activity(user, activity) do
    name = NameGenerator.generate_name(user, activity)
    description = DescriptionGenerator.generate_description(user, activity)
    attrs = %{name: name, description: description}

    Logger.info("Renaming #{activity.id}: #{name}")

    Activities.update_activity_by_id(user, activity.id, attrs)
  end
end

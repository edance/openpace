defmodule Squeeze.Fitbit.ActivityLoader do
  @moduledoc """
  Loads data from fitbit and updates the activity
  """

  alias Squeeze.Accounts.Credential
  alias Squeeze.ActivityMatcher
  alias Squeeze.Dashboard

  def update_or_create_activity(%Credential{} = credential, fitbit_activity) do
    user = credential.user
    activity = map_activity(user, fitbit_activity)

    case ActivityMatcher.get_closest_activity(user, activity) do
      nil -> Dashboard.create_activity(user, activity)
      existing_activity ->
        activity = %{activity | name: existing_activity.name}
        Dashboard.update_activity(existing_activity, activity)
    end
  end

  defp map_activity(user, activity) do
    %{
      name: activity["name"],
      type: String.downcase(activity["activityParentName"]),
      distance: activity["distance"],
      duration: activity["duration"],
      start_at: start_at(user, activity),
      external_id: "#{activity["activityId"]}"
    }
  end

  defp start_at(_user, %{"startDate" => _date, "startTime" => _time}) do
    Timex.now()
  end
end

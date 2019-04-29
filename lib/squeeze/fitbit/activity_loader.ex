defmodule Squeeze.Fitbit.ActivityLoader do
  @moduledoc """
  Loads data from fitbit and updates the activity
  """

  alias Squeeze.Accounts.Credential
  alias Squeeze.Dashboard

  def update_or_create_activity(%Credential{} = credential, activity) do
    user = credential.user
    Dashboard.create_activity(user, map_activity(user, activity))
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

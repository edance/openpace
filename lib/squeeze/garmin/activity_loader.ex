defmodule Squeeze.Garmin.ActivityLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts.{Credential}
  alias Squeeze.ActivityMatcher
  alias Squeeze.Dashboard
  alias Squeeze.Garmin.Client

  def update_or_create_activity(%Credential{} = credential, params) do
    user = credential.user
    activity = build_activity(credential, params)

    case ActivityMatcher.get_closest_activity(user, activity) do
      nil ->
        {:ok, _activity} = Dashboard.create_activity(user, activity)
      existing_activity ->
        activity = %{activity | name: existing_activity.name}
        {:ok, _activity} = Dashboard.update_activity(existing_activity, activity)
    end
  end

  defp build_activity(credential, params) do
    credential
    |> fetch_activity(params["callbackURL"])
    |> map_garmin_activity(params)
  end

  defp fetch_activity(credential, url) do
    credential
    |> Client.new()
    |> Client.get!(url)
    |> Map.get(:body)
    |> List.first() # always returns an array
  end

  # %{
  #   "activityType" => "UNCATEGORIZED",
  #   "averageBikeCadenceInRoundsPerMinute" => 85.39649,
  #   "averageHeartRateInBeatsPerMinute" => 146,
  #   "averagePaceInMinutesPerKilometer" => 4.7924213,
  #   "averageSpeedInMetersPerSecond" => 3.477713,
  #   "deviceName" => "unknown",
  #   "distanceInMeters" => 17437.25,
  #   "durationInSeconds" => 5014,
  #   "manual" => true,
  #   "maxBikeCadenceInRoundsPerMinute" => 90.0,
  #   "maxHeartRateInBeatsPerMinute" => 160,
  #   "maxPaceInMinutesPerKilometer" => 2.966587,
  #   "maxSpeedInMetersPerSecond" => 5.6181283,
  #   "startTimeInSeconds" => 1572198311,
  #   "startTimeOffsetInSeconds" => -25200,
  #   "startingLatitudeInDegree" => 37.777772694826126,
  #   "startingLongitudeInDegree" => -122.43836307898164,
  #   "summaryId" => "4205221034",
  #   "totalElevationGainInMeters" => 107.68638,
  #   "totalElevationLossInMeters" => 107.966805
  # }
  defp map_garmin_activity(obj, params) do
    %{
      type: obj["activityType"],
      distance: obj["distanceInMeters"],
      duration: obj["durationInSeconds"],
      start_at: start_at(obj),
      elevation_gain: obj["totalElevationGainInMeters"],
      external_id: external_id(params),
      planned_date: planned_date(obj)
    }
  end

  defp start_at(%{"startTimeInSeconds" => seconds}) do
    Timex.from_unix(seconds)
  end

  defp external_id(%{"uploadStartTimeInSeconds" => t1, "uploadEndTimeInSeconds" => t2}) do
    "#{t1}&#{t2}"
  end
  defp external_id(_), do: nil

  # startTimeInSeconds (epoch UTC)
  # startTimeOffsetInSeconds (offset to derive local time)
  defp planned_date(%{"startTimeInSeconds" => seconds, "startTimeOffsetInSeconds" => offset}) do
    seconds
    |> Timex.from_unix()
    |> Timex.shift(seconds: offset)
    |> Timex.to_date()
  end
end

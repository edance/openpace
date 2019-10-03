defmodule Squeeze.Strava.ActivityLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts.{Credential}
  alias Squeeze.ActivityMatcher
  alias Squeeze.Dashboard
  alias Squeeze.Strava.Client
  alias Squeeze.Strava.StreamSetConverter

  @strava_activities Application.get_env(:squeeze, :strava_activities)
  @strava_streams Application.get_env(:squeeze, :strava_streams)

  def update_or_create_activity(%Credential{} = credential, strava_activity_id)
  when is_binary(strava_activity_id) or is_integer(strava_activity_id) do
    {:ok, strava_activity} = fetch_strava_activity(credential, strava_activity_id)
    update_or_create_activity(credential, strava_activity)
  end

  def update_or_create_activity(%Credential{} = credential, strava_activity) do
    user = credential.user
    activity = map_strava_activity(strava_activity)
    case ActivityMatcher.get_closest_activity(user, activity) do
      nil ->
        {:ok, activity} = Dashboard.create_activity(user, activity)
        save_trackpoints(credential, activity)
      existing_activity ->
        activity = %{activity | name: existing_activity.name}
        {:ok, activity} = Dashboard.update_activity(existing_activity, activity)
        save_trackpoints(credential, activity)
    end
  end

  defp fetch_strava_activity(%Credential{} = credential, activity_id) do
    credential
    |> Client.new
    |> @strava_activities.get_activity_by_id(activity_id)
  end

  defp map_strava_activity(strava_activity) do
    %{
      name: strava_activity.name,
      type: strava_activity.type,
      distance: strava_activity.distance,
      duration: strava_activity.moving_time,
      start_at: strava_activity.start_date,
      elevation_gain: strava_activity.total_elevation_gain,
      external_id: "#{strava_activity.id}",
      planned_date: Timex.to_date(strava_activity.start_date_local),
      polyline: strava_activity.map.summary_polyline,
      workout_type: strava_activity.workout_type
    }
  end

  defp save_trackpoints(credential, %{external_id: strava_activity_id} = activity) do
    stream_set = fetch_streams(strava_activity_id, credential)
    trackpoints = StreamSetConverter.convert_stream_set_to_trackpoints(stream_set)
    Dashboard.create_trackpoint_set(activity, trackpoints)
  end

  defp fetch_streams(id, credential) do
    client = Client.new(credential)
    streams = "altitude,cadence,distance,time,moving,heartrate,latlng,velocity_smooth"
    {:ok, stream_set} =
      @strava_streams.get_activity_streams(client, id, streams, true)
    stream_set
  end
end

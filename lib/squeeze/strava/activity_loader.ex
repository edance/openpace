defmodule Squeeze.Strava.ActivityLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts.{Credential}
  alias Squeeze.ActivityMatcher
  alias Squeeze.Challenges.ScoreUpdater
  alias Squeeze.Dashboard
  alias Squeeze.Notifications
  alias Squeeze.Strava.{ActivityFormatter, Client, StreamSetConverter}

  @strava_activities Application.get_env(:squeeze, :strava_activities)
  @strava_streams Application.get_env(:squeeze, :strava_streams)

  def update_or_create_activity(%Credential{} = credential, strava_activity_id)
  when is_binary(strava_activity_id) or is_integer(strava_activity_id) do
    {:ok, strava_activity} = fetch_strava_activity(credential, strava_activity_id)
    update_or_create_activity(credential, strava_activity)
  end

  def update_or_create_activity(%Credential{} = credential, strava_activity) do
    user = credential.user
    activity = ActivityFormatter.format(strava_activity)
    case ActivityMatcher.get_closest_activity(user, activity) do
      nil ->
        with {:ok, activity} <- Dashboard.create_activity(user, activity),
             {:ok, _} <- save_trackpoints(credential, activity) do
          Notifications.notify_new_activity(activity)
          ScoreUpdater.update_score(activity)
          {:ok, activity}
        end
      existing_activity ->
        with {:ok, activity} <- Dashboard.update_activity(existing_activity, activity),
             {:ok, _} <- save_trackpoints(credential, activity) do
          {:ok, activity}
        end
    end
  end

  defp fetch_strava_activity(%Credential{} = credential, activity_id) do
    credential
    |> Client.new
    |> @strava_activities.get_activity_by_id(activity_id)
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

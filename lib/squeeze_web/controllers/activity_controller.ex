defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Strava.Client
  alias Strava.Streams

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, current_user) do
    activities = Dashboard.recent_activities(current_user)
    render(conn, "index.html", activities: activities)
  end

  def show(conn, %{"id" => id}, current_user) do
    activity = Dashboard.get_activity!(current_user, id)
    stream_set = fetch_streams(activity, current_user)
    render(conn, "show.html",
      activity: activity,
      altitude: stream_set.altitude.data,
      coordinates: stream_set.latlng.data,
      distance: stream_set.distance.data,
      heartrate: stream_set.heartrate.data)
  end

  defp fetch_streams(activity, user) do
    client = Client.new(user)
    streams = "altitude,heartrate,latlng"
    {:ok, stream_set} =
      Streams.get_activity_streams(client, activity.external_id, streams, true)
    stream_set
  end
end

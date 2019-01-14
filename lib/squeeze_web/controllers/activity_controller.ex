defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Distances
  alias Squeeze.Strava.Client

  @strava_streams Application.get_env(:squeeze, :strava_streams)

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
      altitude: stream_data(stream_set.altitude),
      coordinates: stream_data(stream_set.latlng),
      distance: distance_stream(current_user, stream_data(stream_set.distance)),
      heartrate: stream_data(stream_set.heartrate),
      velocity: stream_data(stream_set.velocity_smooth)
    )
  end

  defp distance_stream(user, data) do
    data
    |> Enum.map(&Distances.to_float(&1, imperial: user.user_prefs.imperial))
  end

  defp stream_data(stream) do
    case stream do
      nil -> []
      stream -> stream.data
    end
  end

  defp fetch_streams(%{external_id: id}, user) do
    client = Client.new(user)
    streams = "altitude,heartrate,latlng,velocity_smooth"
    {:ok, stream_set} =
      @strava_streams.get_activity_streams(client, id, streams, true)
    stream_set
  end
end

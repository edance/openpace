defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Distances
  alias Squeeze.Strava.Client
  alias Squeeze.Velocity

  @strava_streams Application.get_env(:squeeze, :strava_streams)
  @meter_in_feet 3.28084

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, current_user) do
    activities = Dashboard.recent_activities(current_user)
    render(conn, "index.html", activities: activities)
  end

  def show(conn, %{"id" => id}, user) do
    activity = Dashboard.get_activity!(user, id)
    stream_set = fetch_streams(activity, user)
    render(conn, "show.html",
      activity: activity,
      altitude: altitude_stream(user, stream_data(stream_set.altitude)),
      coordinates: stream_data(stream_set.latlng),
      distance: distance_stream(user, stream_data(stream_set.distance)),
      heartrate: stream_data(stream_set.heartrate),
      velocity: velocity_stream(user, stream_data(stream_set.velocity_smooth)),
    )
  end

  defp distance_stream(user, data) do
    data
    |> Enum.map(&Distances.to_float(&1, imperial: user.user_prefs.imperial))
  end

  defp altitude_stream(user, data) do
    if user.user_prefs.imperial do
      data
      |> Enum.map(fn(x) -> x * @meter_in_feet end)
    else
      data
    end
  end

  defp velocity_stream(user, data) do
    Enum.map(data, &Velocity.to_float(&1, imperial: user.user_prefs.imperial))
  end

  defp stream_data(stream) do
    case stream do
      nil -> []
      stream -> stream.data
    end
  end

  defp fetch_streams(%{external_id: id}, user) do
    client = Client.new(user)
    streams = "altitude,cadence,time,moving,heartrate,latlng,velocity_smooth"
    {:ok, stream_set} =
      @strava_streams.get_activity_streams(client, id, streams, true)
    stream_set
  end
end

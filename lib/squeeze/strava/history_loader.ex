defmodule Squeeze.Strava.HistoryLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts
  alias Squeeze.Accounts.{Credential}
  alias Squeeze.Dashboard
  alias Squeeze.Strava.Client
  alias Strava.Paginator

  @strava_activities Application.get_env(:squeeze, :strava_activities)

  def load_recent(%Credential{} = credential) do
    create_activities(credential)
    Accounts.update_credential(credential, %{sync_at: Timex.now})
  end

  defp create_activities(credential) do
    credential
    |> activity_stream
    |> Stream.map(&map_strava_activity/1)
    |> Stream.each(fn(a) -> Dashboard.create_activity(credential.user, a) end)
    |> Enum.to_list()
  end

  defp activity_stream(credential) do
    client = Client.new(credential)
    Paginator.stream(
      fn pagination ->
        @strava_activities.get_logged_in_athlete_activities(client, pagination)
      end,
      query(credential)
    )
  end

  defp query(%{sync_at: nil}), do: [per_page: 100]
  defp query(%{sync_at: sync_at}) do
    [after: DateTime.to_unix(sync_at), per_page: 100]
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
end

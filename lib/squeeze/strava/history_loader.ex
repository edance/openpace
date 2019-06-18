defmodule Squeeze.Strava.HistoryLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts
  alias Squeeze.Accounts.{Credential}
  alias Squeeze.Dashboard
  alias Squeeze.Strava.Client

  @strava_activities Application.get_env(:squeeze, :strava_activities)


  def load_recent(%Credential{} = credential) do
    {:ok, activities} = fetch_activities(credential)
    activities
    |> Enum.map(&map_strava_activity/1)
    |> Enum.each(fn(a) -> Dashboard.create_activity(credential.user, a) end)
    Accounts.update_credential(credential, %{sync_at: Timex.now})
  end

  defp query(%{sync_at: nil}), do: [page: 1, per_page: 100]
  defp query(%{sync_at: sync_at}) do
    [after: DateTime.to_unix(sync_at), per_page: 100]
  end

  defp fetch_activities(credential) do
    query = query(credential)
    credential
    |> Client.new
    |> @strava_activities.get_logged_in_athlete_activities(query)
  end

  defp map_strava_activity(strava_activity) do
    %{
      name: strava_activity.name,
      type: strava_activity.type,
      distance: strava_activity.distance,
      duration: strava_activity.moving_time,
      start_at: strava_activity.start_date,
      external_id: "#{strava_activity.id}",
      polyline: strava_activity.map.summary_polyline
    }
  end
end

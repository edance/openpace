defmodule Squeeze.Sync do
  @moduledoc """
  The Sync context.
  """

  use OAuth2.Strategy

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Squeeze.Accounts.{Credential, User}
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo
  alias Squeeze.Strava.Client

  @strava_activities Application.get_env(:squeeze, :strava_activities)

  @doc """
  Fetch all activities and import into database.
  """
  def load_activities(%User{credential: nil}), do: {:ok, %{}}
  def load_activities(%User{credential: credential} = user) do
    changeset = Credential.changeset(credential, %{sync_at: DateTime.utc_now})
    Multi.new
    |> Multi.insert_all(:activities, Activity, fetch_activities(user))
    |> Multi.update(:credential, changeset)
    |> Repo.transaction()
  end

  defp fetch_activities(%User{credential: %Credential{provider: "strava"}} = user) do
    client = Client.new(user)
    filter = strava_filter(user)
    {:ok, activities} = @strava_activities.get_logged_in_athlete_activities(client, filter)
    activities
    |> Enum.filter(&String.contains?(&1.type, "Run"))
    |> Enum.map(&map_strava_activity(&1, user))
  end
  defp fetch_activities(_), do: []

  defp strava_filter(%User{credential: %Credential{sync_at: nil}}), do: []
  defp strava_filter(%User{credential: %Credential{sync_at: sync_at}}) do
    [after: DateTime.to_unix(sync_at)]
  end

  @doc false
  defp map_strava_activity(x, %User{} = user) do
    %{
      name: x.name,
      distance: x.distance,
      duration: x.moving_time,
      start_at: x.start_date,
      external_id: x.id,
      user_id: user.id,
      polyline: x.map.summary_polyline,
      complete: true,
      inserted_at: DateTime.utc_now,
      updated_at: DateTime.utc_now
    }
  end
end

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
  alias Strava.Client

  def load_activities(%User{credential: nil}), do: []
  def load_activities(%User{credential: credential}) do
    changeset = Credential.changeset(credential, %{sync_at: DateTime.utc_now})
    Multi.new
    |> Multi.insert_all(:activities, Activity, fetch_activities(credential))
    |> Multi.update(:credential, changeset)
    |> Repo.transaction()
  end

  @doc """
  Fetch all activities and import into database.
  """
  def fetch_activities(%Credential{provider: "strava"} = credential) do
    client = Client.new(credential.token)
    filter = strava_filter(credential)
    %Strava.Pagination{}
    |> Strava.Activity.list_athlete_activities(filter, client)
    |> Enum.map(&map_strava_activity(&1, credential.user_id))
  end
  def fetch_activities(_), do: []

  defp strava_filter(%Credential{sync_at: nil}), do: %{}
  defp strava_filter(%Credential{sync_at: sync_at}) do
    %{after: DateTime.to_unix(sync_at)}
  end

  @doc false
  defp map_strava_activity(x, user_id) do
    %{
      name: x.name,
      distance: x.distance,
      duration: x.moving_time,
      start_at: x.start_date,
      external_id: x.id,
      user_id: user_id,
      inserted_at: DateTime.utc_now,
      updated_at: DateTime.utc_now
    }
  end
end

defmodule Squeeze.Sync do
  @moduledoc """
  The Sync context.
  """

  use OAuth2.Strategy

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.{Credential, User}
  alias Squeeze.Repo
  alias Squeeze.Dashboard.Activity
  alias Ecto.Multi

  def load_activities(%User{ credential: nil }) do
    []
  end

  def load_activities(%User{ credential: credential }) do
    changeset = Credential.changeset(credential, %{sync_at: DateTime.utc_now})
    Multi.new
    |> Multi.insert_all(:activities, Activity, fetch_activities(credential))
    |> Multi.update(:credential, changeset)
    |> Repo.transaction()
  end

  @doc """
  Fetch all activities and import into database.
  """
  def fetch_activities(%Credential{ provider: "strava"} = credential) do
    client = Strava.Client.new(credential.token)
    pagination = %Strava.Pagination{}
    filter = strava_filter(credential)
    Strava.Activity.list_athlete_activities(pagination, filter, client)
    |> Enum.map(&map_strava_activity(&1, credential.user_id))
  end

  def fetch_activities(_) do
    []
  end

  defp strava_filter(%Credential{ sync_at: nil }) do
    %{}
  end

  defp strava_filter(%Credential{ sync_at: sync_at }) do
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

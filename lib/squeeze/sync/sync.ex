defmodule Squeeze.Sync do
  @moduledoc """
  The Sync context.
  """

  use OAuth2.Strategy

  import Ecto.Query, warn: false
  alias Squeeze.Accounts
  alias Squeeze.Accounts.{Credential, User}
  alias Squeeze.Strava.ActivityLoader
  alias Squeeze.Strava.Client

  @strava_activities Application.get_env(:squeeze, :strava_activities)

  @doc """
  Fetch all activities and import into database.
  """
  def load_activities(%User{credential: nil}), do: {:ok, %{}}
  def load_activities(%User{credential: credential} = user) do
    activities = user
    |> fetch_activities()
    |> Enum.map(&ActivityLoader.update_or_create_activity(user, &1))
    Accounts.update_credential(credential, %{sync_at: Timex.now})
    activities
  end

  defp fetch_activities(%User{credential: %Credential{provider: "strava"}} = user) do
    client = Client.new(user)
    filter = strava_filter(user)
    {:ok, activities} = @strava_activities.get_logged_in_athlete_activities(client, filter)
    activities
  end
  defp fetch_activities(_), do: []

  defp strava_filter(%User{credential: %Credential{sync_at: nil}}), do: []
  defp strava_filter(%User{credential: %Credential{sync_at: sync_at}}) do
    [after: DateTime.to_unix(sync_at)]
  end
end

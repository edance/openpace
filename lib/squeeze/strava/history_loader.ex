defmodule Squeeze.Strava.HistoryLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts
  alias Squeeze.Accounts.{Credential, User}
  alias Squeeze.Dashboard
  alias Squeeze.Strava.{ActivityFormatter, Client}
  alias Strava.Paginator

  @strava_activities Application.compile_env(:squeeze, :strava_activities)

  def load_recent(%Credential{} = credential) do
    load_recent(credential.user, credential)
  end

  def load_recent(%User{} = user, %Credential{} = credential) do
    create_activities(user, credential)
    Accounts.update_credential(credential, %{sync_at: Timex.now})
  end

  defp create_activities(user, credential) do
    credential
    |> activity_stream
    |> Stream.map(&ActivityFormatter.format/1)
    |> Stream.each(fn(a) -> Dashboard.create_activity(user, a) end)
    |> Enum.to_list()
  end

  defp activity_stream(credential) do
    client = Client.new(credential)
    query = query(credential)

    Paginator.stream(
      fn pagination ->
        pagination = Keyword.merge(pagination, query)
        @strava_activities.get_logged_in_athlete_activities(client, pagination)
      end,
      per_page: 30
    )
  end

  defp query(%{sync_at: nil}), do: []
  defp query(%{sync_at: sync_at}) do
    [after: DateTime.to_unix(sync_at)]
  end
end

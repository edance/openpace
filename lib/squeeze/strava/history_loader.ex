defmodule Squeeze.Strava.HistoryLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts
  alias Squeeze.Accounts.{Credential}
  alias Squeeze.Dashboard
  alias Squeeze.Strava.{ActivityFormatter, Client}
  alias Strava.Paginator

  @strava_activities Application.compile_env(:squeeze, :strava_activities)

  def load_recent(%Credential{} = credential) do
    create_activities(credential)
    Accounts.update_credential(credential, %{sync_at: Timex.now})
  end

  defp create_activities(credential) do
    credential
    |> activity_stream
    |> Stream.map(&ActivityFormatter.format/1)
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

  defp query(%{sync_at: nil}), do: [per_page: 50]
  defp query(%{sync_at: sync_at}) do
    [after: DateTime.to_unix(sync_at), per_page: 50]
  end
end

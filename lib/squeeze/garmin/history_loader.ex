defmodule Squeeze.Garmin.HistoryLoader do
  @moduledoc false

  alias Squeeze.Accounts.{Credential}
  alias Squeeze.Garmin.Client

  # GET https://healthapi.garmin.com/wellness-api/rest/backfill/activities
  # summaryStartTimeInSeconds summaryEndTimeInSeconds
  # limits to 90 days

  def load_recent(%Credential{} = credential) do
    trigger_activity_backfill(credential)
  end

  defp trigger_activity_backfill(credential) do
    now = Timex.now()
    end_time = Timex.to_unix(now)
    start_time = now |> Timex.shift(days: -90) |> Timex.to_unix()
    query = "summaryStartTimeInSeconds=#{start_time}&summaryEndTimeInSeconds=#{end_time}"
    url = "https://healthapi.garmin.com/wellness-api/rest/backfill/activities?#{query}"

    credential
    |> Client.new()
    |> Client.get(url)
  end
end

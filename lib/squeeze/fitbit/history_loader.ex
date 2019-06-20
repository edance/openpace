defmodule Squeeze.Fitbit.HistoryLoader do
  @moduledoc """
  Loads the last 20 events from fitbit and finds matching activities
  """

  alias Squeeze.Accounts
  alias Squeeze.Accounts.{Credential}
  alias Squeeze.Fitbit.Client
  alias Squeeze.Fitbit.ActivityLoader

  def load_recent(%Credential{} = credential) do
    case fetch_activities(credential) do
      {:ok, response} ->
        response.body["activities"]
        |> Enum.each(&(ActivityLoader.update_or_create_activity(credential, &1)))
        Accounts.update_credential(credential, %{sync_at: Timex.now})
      _ -> {:error}
    end
  end

  defp fetch_activities(credential) do
    credential
    |> Client.new()
    |> Client.get_activities()
  end
end

defmodule Squeeze.Fitbit.HistoryLoader do
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Accounts.Credential
  alias Squeeze.Fitbit.{ActivityLoader, Client}

  def load_recent(%Credential{} = credential) do
    case fetch_activities(credential) do
      {:ok, response} ->
        response.body["activities"]
        |> Enum.each(&ActivityLoader.update_or_create_activity(credential, &1))

        Accounts.update_credential(credential, %{sync_at: Timex.now()})

      _ ->
        {:error}
    end
  end

  defp fetch_activities(credential) do
    credential
    |> Client.new()
    |> Client.get_activities()
  end
end

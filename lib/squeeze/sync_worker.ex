defmodule Squeeze.SyncWorker do
  alias Squeeze.Accounts
  alias Squeeze.Sync

  @moduledoc """
  Worker to sync activities for users
  """

  def perform(user_id) do
    user_id
    |> Accounts.get_user!()
    |> Sync.load_activities()
  end
end

defmodule Squeeze.Tasks.ResyncStravaActivities do
  @moduledoc """
  A task to resync all strava activities for all users.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.Credential
  alias Squeeze.Repo

  @doc """
    Run the task
  """
  def run do
    # Get all strava users
    from(c in Credential,
      where: c.provider == "strava",
      preload: [:user]
    )
    |> Repo.all()
    |> Enum.each(&resync_activities/1)
  end

  defp resync_activities(%Credential{} = credential) do
    Squeeze.Strava.HistoryLoader.load_all(credential)
  end
end

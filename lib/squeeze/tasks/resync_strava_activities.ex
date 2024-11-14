defmodule Squeeze.Tasks.ResyncStravaActivities do
  @moduledoc """
  A task to resync all strava activities for all users.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.Credential
  alias Squeeze.Repo
  alias Squeeze.Strava.HistoryLoader
  alias Squeeze.Strava.Client

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

  @doc """
  Checks if the credential still has valid access to Strava
  Returns {:ok, athlete} if valid, {:error, reason} if not
  """
  def verify_access(%Credential{} = credential) do
    client = Client.new(credential)

    case Strava.Athletes.get_logged_in_athlete(client) do
      {:ok, athlete} -> {:ok, athlete}
      {:error, %{status: 401}} -> {:error, :unauthorized}
      {:error, reason} -> {:error, reason}
    end
  end

  defp resync_activities(%Credential{} = credential) do
    case verify_access(credential) do
      {:ok, _athlete} ->
        HistoryLoader.load_all(credential)

      {:error, reason} ->
        IO.puts("Failed to sync activities for user: #{credential.user.email}, reason: #{reason}")
        {:error, reason}
    end
  end
end

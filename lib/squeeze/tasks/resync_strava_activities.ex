defmodule Squeeze.Tasks.ResyncStravaActivities do
  @moduledoc """
  A task to resync all strava activities for all users.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Accounts.Credential
  alias Squeeze.Repo
  alias Squeeze.Strava.{Client, HistoryLoader}

  require Logger

  @doc """
  Run the task to resync Strava activities.

  ## Options
    * `:user_id` - Optional user ID to sync activities for a specific user
    * `:silent` - Boolean to suppress output messages. Defaults to false

  ## Examples
      # Sync all users
      iex> ResyncStravaActivities.run()

      # Sync specific user
      iex> ResyncStravaActivities.run(user_id: 123)

      # Sync silently
      iex> ResyncStravaActivities.run(silent: true)
  """
  def run(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    silent = Keyword.get(opts, :silent, false)

    credentials_query =
      from(c in Credential,
        where: c.provider == "strava",
        preload: [:user]
      )

    credentials_query =
      if user_id do
        from(c in credentials_query, where: c.user_id == ^user_id)
      else
        credentials_query
      end

    credentials_query
    |> Repo.all()
    |> Enum.each(&resync_activities(&1, silent))
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
      {:error, _} -> {:error, :unknown}
    end
  end

  defp resync_activities(%Credential{} = credential, silent) do
    case verify_access(credential) do
      {:ok, _athlete} ->
        HistoryLoader.load_all(credential)

      {:error, reason} ->
        unless silent do
          Logger.warn(
            "Failed to sync activities for user: #{credential.user.email}, reason: #{reason}"
          )
        end

        {:error, reason}
    end
  end
end

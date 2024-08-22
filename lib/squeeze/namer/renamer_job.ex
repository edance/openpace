defmodule Squeeze.Namer.RenamerJob do
  @moduledoc """
  Basic job to retry naming 3 times.
  """
  require Logger

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Namer.ActivityRenamer

  def perform(strava_uid, activity_id, retry \\ 3)
  def perform(_, _, 0), do: :ignore
  def perform(%User{user_prefs: %{rename_activities: false}}, _, _), do: :ignore

  def perform(%User{} = user, activity_id, retry) do
    Logger.info("Starting job for #{user.id} for activity #{activity_id}")

    :timer.sleep(:timer.minutes(1))

    case ActivityRenamer.rename(user, activity_id) do
      {:ok, _} ->
        :ok

      _ ->
        perform(user, activity_id, retry - 1)
    end
  end

  def perform(strava_uid, activity_id, retry) do
    case Accounts.get_user_by_credential(%{provider: "strava", uid: strava_uid}) do
      nil -> :error
      user -> perform(user, activity_id, retry)
    end
  end
end

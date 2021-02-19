defmodule Squeeze.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  import Ecto.Query, warn: false
  alias Ecto.{Changeset, Multi}
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, Trackpoint, TrackpointSet}
  alias Squeeze.Repo
  alias Squeeze.TimeHelper

  @doc """
  Returns the list of activities by user in a date range.

  ## Examples

  iex> list_activities(user, date_range)
  [%Activity{}, ...]

  """
  def list_activities(%User{} = user, date_range) do
    Activity
    |> by_user(user)
    |> by_date_range(user, date_range)
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Returns the list of recent activities by user.

  ## Examples

  iex> recent_activities(user)
  [%Activity{}, ...]

  """
  def recent_activities(%User{} = user) do
    Activity
    |> by_user(user)
    |> where([a], not(is_nil(a.start_at)))
    |> order_by([a], [desc: a.start_at])
    |> Repo.all
    |> Repo.preload(:user)
  end

  def todays_activities(%User{} = user) do
    get_activities_by_date(user, TimeHelper.today(user))
  end

  def get_activities_by_date(%User{} = user, date) do
    Activity
    |> by_user(user)
    |> by_date(user, date)
    |> Repo.all()
  end

  def get_pending_activities_by_date(%User{} = user, date) do
    Activity
    |> by_user(user)
    |> by_date(user, date)
    |> status(:pending)
    |> Repo.all()
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_activity!(%User{}, 123)
      %Activity{}

      iex> get_activity!(%User{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_activity!(%User{} = user, id) do
    Activity
    |> by_user(user)
    |> Repo.get!(id)
    |> Repo.preload([:user])
  end

  def get_activity_by_external_id!(%User{} = user, external_id) do
    Activity
    |> by_user(user)
    |> Repo.get_by!(external_id: external_id)
    |> Repo.preload([:user])
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_detailed_activity!(%User{}, 123)
      %Activity{}

      iex> get_detailed_activity!(%User{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_detailed_activity!(%User{} = user, id) do
    trackpoint_query = from t in Trackpoint, order_by: t.time
    trackpoint_set_query = from ts in TrackpointSet,
      order_by: ts.inserted_at,
      limit: 1,
      preload: [trackpoints: ^trackpoint_query]

    Activity
    |> by_user(user)
    |> Repo.get!(id)
    |> Repo.preload([:user, trackpoint_set: trackpoint_set_query])
  end

  @doc """
  Creates a activity.

  ## Examples

      iex> create_activity(%User{}, %{field: value})
      {:ok, %Activity{}}

      iex> create_activity(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity(%User{} = user, attrs \\ %{}) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a activity.

  ## Examples

  iex> update_activity(activity, %{field: new_value})
  {:ok, %Activity{}}

  iex> update_activity(activity, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an Activity.

  ## Examples

  iex> delete_activity(activity)
  {:ok, %Activity{}}

  iex> delete_activity(activity)
  {:error, %Ecto.Changeset{}}

  """
  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

  iex> change_activity(activity)
  %Ecto.Changeset{source: %Activity{}}

  """
  def change_activity(%Activity{} = activity) do
    Activity.changeset(activity, %{})
  end

  def create_trackpoint_set(%Activity{} = activity, trackpoints) do
    changeset = %TrackpointSet{}
    |> TrackpointSet.changeset()
    |> Changeset.put_change(:activity_id, activity.id)
    Multi.new()
    |> Multi.insert(:trackpoint_set, changeset)
    |> Multi.run(:trackpoint_count, fn(repo, %{trackpoint_set: trackpoint_set}) ->
      trackpoints = trackpoints
      |> Enum.map(&Map.merge(&1, %{trackpoint_set_id: trackpoint_set.id}))
      {count, _} = repo.insert_all(Trackpoint, trackpoints)
      {:ok, count}
    end)
    |> Repo.transaction()
  end

  defp by_user(query, %User{} = user) do
    from q in query, where: [user_id: ^user.id]
  end

  defp by_date(query, %User{} = user, date) do
    start_at = TimeHelper.beginning_of_day(user, date)
    end_at = TimeHelper.end_of_day(user, date)
    from q in query,
      where: (q.start_at >= ^start_at and q.start_at <= ^end_at) or (q.planned_date == ^date)
  end

  defp by_date_range(query, %User{} = user, date_range) do
    start_at = TimeHelper.beginning_of_day(user, date_range.first)
    end_at = TimeHelper.end_of_day(user, date_range.last)
    from q in query,
      where: (q.start_at >= ^start_at and q.start_at <= ^end_at) or
             (q.planned_date >= ^date_range.first and q.planned_date <= ^date_range.last)
  end

  defp status(query, status) do
    from q in query, where: [status: ^status]
  end
end

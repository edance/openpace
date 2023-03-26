defmodule Squeeze.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, ActivityLap, TrackpointSet}
  alias Squeeze.Races
  alias Squeeze.Repo
  alias Squeeze.TimeHelper

  @doc """
  Returns the list of activities by user in a date range.

  ## Examples

  ```elixir
  iex> list_activities(user, date_range)
  [%Activity{}, ...]
  ```
  """
  def list_activities(%User{} = user, date_range) do
    Activity
    |> by_user(user)
    |> by_date_range(date_range)
    |> order_by([a], desc: a.start_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def list_activity_summaries(%User{} = user) do
    # time_window = Timex.now() |> Timex.shift(years: -1)

    query =
      from a in Activity,
        where: a.status == :complete,
        # where: a.start_at > ^time_window,
        where: [user_id: ^user.id],
        order_by: [desc: :start_at],
        select: %{
          slug: a.slug,
          name: a.name,
          distance: a.distance,
          duration: a.duration,
          elevation_gain: a.elevation_gain,
          activity_type: a.activity_type,
          workout_type: a.workout_type,
          start_at_local: a.start_at_local
        }

    Repo.all(query)
  end

  def list_activity_exports(%User{} = user) do
    query =
      from a in Activity,
        where: a.status == :complete,
        where: [user_id: ^user.id],
        order_by: [desc: :start_at],
        select: %{
          distance: a.distance,
          duration: a.duration,
          elevation_gain: a.elevation_gain,
          type: a.type,
          workout_type: a.workout_type,
          start_at_local: a.start_at_local
        }

    Repo.all(query)
  end

  @doc """
  Returns the list of recent activities by user.

  ## Examples

  iex> recent_activities(user)
  [%Activity{}, ...]

  """
  def recent_activities(%User{} = user, page \\ 1) do
    Activity
    |> by_user(user)
    |> where([a], not is_nil(a.start_at))
    |> order_by([a], desc: a.start_at)
    |> by_page(page)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def todays_activities(%User{} = user) do
    get_activities_by_date(user, TimeHelper.today(user))
  end

  def get_activities_by_date(%User{} = user, date) do
    Activity
    |> by_user(user)
    |> by_date(date)
    |> Repo.all()
  end

  def get_pending_activities_by_date(%User{} = user, date) do
    Activity
    |> by_user(user)
    |> by_date(date)
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

  def fetch_activity_by_external_id(%User{} = user, external_id) do
    activity =
      Activity
      |> by_user(user)
      |> Repo.get_by(external_id: external_id)
      |> Repo.preload([:user])

    if activity do
      {:ok, activity}
    else
      {:error, :not_found}
    end
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

      iex> get_detailed_activity_by_slug!(%User{}, 123)
      %Activity{}

      iex> get_detailed_activity_by_slug!(%User{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_detailed_activity_by_slug!(%User{} = user, slug) do
    query =
      from a in Activity,
        where: a.slug == ^slug,
        where: [user_id: ^user.id],
        preload: [:user, :trackpoint_set, :laps]

    Repo.one!(query)
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
    |> Repo.insert_with_slug()
    |> create_goal_if_race()
  end

  defp create_goal_if_race({:ok, %Activity{} = activity}) do
    if activity.workout_type == :race do
      Races.create_race_goal_from_activity(activity)
      {:ok, activity}
    else
      {:ok, activity}
    end
  end

  defp create_goal_if_race(res), do: res

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
    %TrackpointSet{}
    |> TrackpointSet.changeset()
    |> Changeset.put_change(:activity_id, activity.id)
    |> Changeset.put_embed(:trackpoints, trackpoints)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :activity_id)
  end

  def create_laps(%Activity{} = _activity, laps) do
    laps =
      Enum.map(laps, fn row ->
        now = Timex.now() |> Timex.to_naive_datetime() |> NaiveDateTime.truncate(:second)

        row
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

    {count, _} =
      Repo.insert_all(
        ActivityLap,
        laps,
        on_conflict: {:replace_all_except, [:id]},
        conflict_target: [:split, :activity_id]
      )

    {:ok, count}
  end

  defp by_user(query, %User{} = user) do
    from q in query, where: [user_id: ^user.id]
  end

  defp by_date(query, date) do
    start_at = Timex.beginning_of_day(date) |> Timex.to_datetime()
    end_at = Timex.end_of_day(date) |> Timex.to_datetime()

    from q in query,
      where:
        (q.start_at_local >= ^start_at and q.start_at_local <= ^end_at) or q.planned_date == ^date
  end

  defp by_date_range(query, date_range) do
    start_at = Timex.beginning_of_day(date_range.first) |> Timex.to_datetime()
    end_at = Timex.end_of_day(date_range.last) |> Timex.to_datetime()

    from q in query,
      where:
        (q.start_at_local >= ^start_at and q.start_at_local <= ^end_at) or
          (q.planned_date >= ^date_range.first and q.planned_date <= ^date_range.last)
  end

  defp by_page(query, page, page_size \\ 24) do
    offset = page_size * (page - 1)
    from q in query, offset: ^offset, limit: ^page_size
  end

  defp status(query, status) do
    from q in query, where: [status: ^status]
  end
end

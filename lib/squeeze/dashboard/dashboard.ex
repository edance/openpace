defmodule Squeeze.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo
  alias Squeeze.TimeHelper

  @doc """
  Returns the list of activities by user in a date range.

  ## Examples

  iex> list_activities(user, date_range)
  [%Activity{}, ...]

  """
  def list_activities(%User{} = user, _date_range) do
    Activity
    |> by_user(user)
    |> order_by([a], a.start_at)
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
    |> by_date(date)
    |> Repo.all()
  end

  def get_incomplete_activities_by_date(%User{} = user, date) do
    Activity
    |> by_user(user)
    |> by_date(date)
    |> incomplete()
    |> Repo.all()
  end

  @doc """
  Gets a planned activity for the user on the specific date
  """
  def get_planned_activity(%User{} = user, %{start_at: start_at}) do
    date = TimeHelper.to_date(user, start_at)
    Activity
    |> by_user(user)
    |> where([a], is_nil(a.start_at))
    |> where([a], a.planned_date == ^date)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_activity!(123)
      %Activity{}

      iex> get_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity!(id) do
    Activity
    |> Repo.get!(id)
    |> Repo.preload(:user)
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
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

  iex> change_activity(activity)
  %Ecto.Changeset{source: %Activity{}}

  """
  def change_activity(%Activity{} = activity) do
    Activity.changeset(activity, %{})
  end

  defp by_user(query, %User{} = user) do
    from q in query, where: [user_id: ^user.id]
  end

  defp by_date(query, date) do
    from q in query, where: [planned_date: ^date]
  end

  defp incomplete(query) do
    from q in query, where: [complete: false]
  end
end

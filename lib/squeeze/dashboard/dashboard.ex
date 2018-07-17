defmodule Squeeze.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  use OAuth2.Strategy

  import Ecto.Query, warn: false
  alias Squeeze.Repo
  alias Squeeze.Accounts.User

  alias Squeeze.Dashboard.Activity

  @doc """
  Fetch all strava activities and import into database.
  """
  def fetch_activities(user) do
    client = Strava.Client.new(user.credential.token)
    pagination = %Strava.Pagination{per_page: 50, page: 1}
    ids = existing_activity_ids(user)
    Strava.Activity.list_athlete_activities(pagination, %{}, client)
    |> Enum.map(&map_strava_activity(&1))
    |> Enum.filter(fn(x) -> !Enum.member?(ids, x.external_id) end)
    |> Enum.map(&create_activity(user, &1))
  end

  @doc false
  defp map_strava_activity(x) do
    %{name: x.name, distance: x.distance, duration: x.moving_time,
      start_at: x.start_date, external_id: x.id}
  end

  @doc false
  defp existing_activity_ids(user) do
    Activity
    |> where([a], a.user_id == ^user.id)
    |> select([a], a.external_id)
    |> Repo.all
  end

  @doc """
  Returns the list of activities by user.

  ## Examples

      iex> list_activities(user)
      [%Activity{}, ...]

  """
  def list_activities(user) do
    Activity
    |> where([a], a.user_id == ^user.id)
    |> Repo.all
    |> Repo.preload(:user)
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
    |> Ecto.Changeset.put_change(:user_id, user.id)
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
  Deletes a Activity.

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

  alias Squeeze.Dashboard.Goal

  @doc """
  Returns the list of goals by user.

  ## Examples

      iex> list_goals(user)
      [%Goal{}, ...]

  """
  def list_goals(user) do
    Goal
    |> where([a], a.user_id == ^user.id)
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Returns the users current goal.

  ## Examples

    iex> get_current_goal(user)
    %Goal{}

  """
  def get_current_goal(user) do
    query = from g in Goal,
      where: g.user_id == ^user.id,
      order_by: [desc: g.id],
      limit: 1

    Repo.one(query)
  end

  @doc """
  Returns a list of todays activities.

  ## Examples

    iex> get_todays_activities(user)
    [%Activity{}, ...]
  """
  def get_todays_activities(_user) do
    []
  end

  @doc """
  Gets a single goal.

  Raises `Ecto.NoResultsError` if the Goal does not exist.

  ## Examples

      iex> get_goal!(123)
      %Goal{}

      iex> get_goal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_goal!(id) do
    Goal
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a goal.

  ## Examples

      iex> create_goal(%User{}, %{field: value})
      {:ok, %Goal{}}

      iex> create_goal(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_goal(%User{} = user, attrs \\ %{}) do
    %Goal{}
    |> Goal.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a goal.

  ## Examples

      iex> update_goal(goal, %{field: new_value})
      {:ok, %Goal{}}

      iex> update_goal(goal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_goal(%Goal{} = goal, attrs) do
    goal
    |> Goal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Goal.

  ## Examples

      iex> delete_goal(goal)
      {:ok, %Goal{}}

      iex> delete_goal(goal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_goal(%Goal{} = goal) do
    Repo.delete(goal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking goal changes.

  ## Examples

      iex> change_goal(goal)
      %Ecto.Changeset{source: %Goal{}}

  """
  def change_goal(%Goal{} = goal) do
    Goal.changeset(goal, %{})
  end

  alias Squeeze.Dashboard.Pace

  @doc """
  Returns the list of paces by user.

  ## Examples

      iex> list_paces(user)
      [%Pace{}, ...]

  """
  def list_paces(user) do
    Pace
    |> where([a], a.user_id == ^user.id)
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single pace.

  Raises `Ecto.NoResultsError` if the Pace does not exist.

  ## Examples

      iex> get_pace!(123)
      %Pace{}

      iex> get_pace!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pace!(id) do
    Pace
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a pace.

  ## Examples

      iex> create_pace(%User{}, %{field: value})
      {:ok, %Pace{}}

      iex> create_pace(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pace(%User{} = user, attrs \\ %{}) do
    %Pace{}
    |> Pace.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a pace.

  ## Examples

      iex> update_pace(pace, %{field: new_value})
      {:ok, %Pace{}}

      iex> update_pace(pace, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pace(%Pace{} = pace, attrs) do
    pace
    |> Pace.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Pace.

  ## Examples

      iex> delete_pace(pace)
      {:ok, %Pace{}}

      iex> delete_pace(pace)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pace(%Pace{} = pace) do
    Repo.delete(pace)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pace changes.

  ## Examples

      iex> change_pace(pace)
      %Ecto.Changeset{source: %Pace{}}

  """
  def change_pace(%Pace{} = pace) do
    Pace.changeset(pace, %{})
  end

  alias Squeeze.Dashboard.Event

  @doc """
  Returns the list of events by user.

  ## Examples

      iex> list_events(user)
      [%Event{}, ...]

  """
  def list_events(user, dates) do
    Event
    |> where([a], a.user_id == ^user.id)
    |> where([a], a.date >= ^dates.first)
    |> where([a], a.date <= ^dates.last)
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id) do
    Event
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%User{}, %{field: value})
      {:ok, %Event{}}

      iex> create_event(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(%User{} = user, attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end
end

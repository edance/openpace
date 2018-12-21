defmodule Squeeze.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Repo

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

  alias Squeeze.Dashboard.Event

  @doc """
  Returns the list of events by user in a date range.

  ## Examples

      iex> list_events(user, date_range)
      [%Event{}, ...]

  """
  def list_events(%User{} = user, date_range) do
    Event
    |> where([a], a.user_id == ^user.id)
    |> where([a], a.date >= ^date_range.first)
    |> where([a], a.date <= ^date_range.last)
    |> order_by([a], a.date)
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Returns list of events by user in the past including today.

  ## Examples

      iex> list_past_events(user)
      [%Event{}, ...]

  """
  def list_past_events(%User{} = user) do
    Event
    |> where([a], a.user_id == ^user.id)
    |> where([a], a.date <= ^Date.utc_today())
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
    |> Changeset.put_change(:user_id, user.id)
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

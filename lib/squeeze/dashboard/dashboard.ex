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
  Returns the list of activities by user in a date range.

  ## Examples

  iex> list_activities(user, date_range)
  [%Activity{}, ...]

  """
  def list_activities(%User{} = user, _date_range) do
    Activity
    |> where([a], a.user_id == ^user.id)
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
    |> where([a], a.user_id == ^user.id)
    |> where([a], not(is_nil(a.start_at)))
    |> order_by([a], [desc: a.start_at])
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
end

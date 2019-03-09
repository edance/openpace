defmodule Squeeze.Dashboard.Activity do
  @moduledoc """
  This module contains the schema for the activity. Activities are pulled from
  different services.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, Trackpoint}

  @required_fields ~w(name)a
  @optional_fields ~w(
    planned_distance
    planned_duration
    planned_date
    distance
    start_at
    duration
    external_id
    polyline
  )a

  schema "activities" do
    field :name, :string

    # Planning Fields
    field :planned_distance, :float
    field :planned_duration, :integer
    field :planned_date, :date

    # Fields for after activity is completed
    field :distance, :float
    field :duration, :integer
    field :start_at, :naive_datetime
    field :polyline, :string
    field :external_id, :string

    field :status, ActivityStatusEnum
    field :complete, :boolean

    belongs_to :user, User

    has_many :trackpoints, Trackpoint

    timestamps()
  end

  @doc false
  def changeset(%Activity{} = activity, attrs) do
    activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> set_status()
  end

  # pending, complete, incomplete, partial
  defp set_status(changeset) do
    planned_distance = get_field(changeset, :planned_distance)
    distance = get_field(changeset, :distance)
    cond do
      is_nil(distance) ->
        changeset
      is_nil(planned_distance) ->
        cast_status(changeset, :complete)
      percent_complete(planned_distance, distance) >= 0.95 ->
        cast_status(changeset, :complete)
      true ->
        cast_status(changeset, :partial)
    end
  end

  defp percent_complete(planned_distance, distance) do
    distance / planned_distance
  end

  def cast_status(changeset, status) do
    cast(changeset, %{status: status}, [:status])
  end
end

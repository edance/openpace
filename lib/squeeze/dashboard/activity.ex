defmodule Squeeze.Dashboard.Activity do
  @moduledoc """
  This module contains the schema for the activity. Activities are pulled from
  different services.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, TrackpointSet}
  alias Squeeze.Distances

  @required_fields ~w(type)a
  @optional_fields ~w(
    name
    planned_distance
    planned_distance_amount
    planned_distance_unit
    planned_duration
    planned_date
    distance
    distance_amount
    distance_unit
    start_at
    duration
    description
    external_id
    polyline
  )a

  schema "activities" do
    field :name, :string
    field :type, :string

    # Planning Fields
    field :planned_distance, :float # in meters
    field :planned_distance_amount, :float
    field :planned_distance_unit, DistanceUnitEnum
    field :planned_duration, :integer
    field :planned_date, :date

    # Fields for after activity is completed
    field :distance, :float # in meters
    field :distance_amount, :float
    field :distance_unit, DistanceUnitEnum
    field :duration, :integer
    field :start_at, :utc_datetime
    field :polyline, :string
    field :external_id, :string

    field :description, :string

    field :status, ActivityStatusEnum
    field :complete, :boolean

    belongs_to :user, User

    has_one :trackpoint_set, TrackpointSet

    timestamps()
  end

  @doc false
  def changeset(%Activity{} = activity, attrs) do
    activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:unique_activity, name: :activities_user_id_external_id_index)
    |> calculate_distances()
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

  defp calculate_distances(changeset) do
    distance_amount = get_field(changeset, :distance_amount)
    distance_unit = get_field(changeset, :distance_unit)
    distance = distance_to_meters(distance_amount, distance_unit)
    planned_amount = get_field(changeset, :planned_distance_amount)
    planned_unit = get_field(changeset, :planned_distance_unit)
    planned_distance = distance_to_meters(planned_amount, planned_unit)

    changeset
    |> put_change(:distance, distance)
    |> put_change(:planned_distance, planned_distance)
  end

  defp percent_complete(planned_distance, distance) do
    distance / planned_distance
  end

  defp distance_to_meters(nil, _), do: nil
  defp distance_to_meters(amount, unit), do: Distances.to_meters(amount, unit)

  def cast_status(changeset, status) do
    cast(changeset, %{status: status}, [:status])
  end
end

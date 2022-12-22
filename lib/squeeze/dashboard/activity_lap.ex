defmodule Squeeze.Dashboard.ActivityLap do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Dashboard.{Activity}

  # @required_fields ~w(type)a
  # @optional_fields ~w(
  #   activity_type
  #   name
  #   workout_type
  #   planned_distance
  #   planned_distance_amount
  #   planned_distance_unit
  #   planned_duration
  #   planned_date
  #   distance
  #   distance_amount
  #   distance_unit
  #   start_at
  #   start_at_local
  #   duration
  #   description
  #   elevation_gain
  #   external_id
  #   polyline
  # )a

  schema "activity_laps" do
    field :average_cadence, :float
    field :average_speed, :float
    field :distance, :float
    field :elapsed_time, :integer
    field :end_index, :integer
    field :lap_index, :integer
    field :max_speed, :float
    field :moving_time, :integer
    field :name, :string
    field :pace_zone, :integer
    field :split, :integer
    field :start_date, :naive_datetime
    field :start_date_local, :naive_datetime
    field :start_index, :integer
    field :total_elevation_gain, :float

    belongs_to :activity, Activity

    timestamps()
  end

  @doc false
  def changeset(activity_lap, attrs) do
    activity_lap
    |> cast(attrs, [:average_cadence, :average_speed, :distance, :elapsed_time, :start_index, :end_index, :lap_index, :max_speed, :moving_time, :name, :pace_zone, :split, :start_date, :start_date_local, :total_elevation_gain])
    |> validate_required([:average_cadence, :average_speed, :distance, :elapsed_time, :start_index, :end_index, :lap_index, :max_speed, :moving_time, :name, :pace_zone, :split, :start_date, :start_date_local, :total_elevation_gain])
  end
end

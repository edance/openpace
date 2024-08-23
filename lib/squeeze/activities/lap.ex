defmodule Squeeze.Activities.Lap do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Activities.Activity

  @required_fields ~w(
    average_cadence
    average_speed
    distance
    elapsed_time
    end_index
    lap_index
    max_speed
    moving_time
    name
    pace_zone
    split
    start_date
    start_date_local
    start_index
    total_elevation_gain
  )a
  @optional_fields ~w()a

  @derive {Jason.Encoder, only: @required_fields ++ @optional_fields}

  schema "activity_laps" do
    field :average_cadence, :float
    field :average_speed, :float
    field :distance, :float
    field :elapsed_time, :integer
    field :lap_index, :integer
    field :max_speed, :float
    field :moving_time, :integer
    field :name, :string
    field :pace_zone, :integer
    field :split, :integer
    field :start_date, :naive_datetime
    field :start_date_local, :naive_datetime
    field :total_elevation_gain, :float

    # Start and end indices of the trackpoints in the lap
    field :start_index, :integer
    field :end_index, :integer

    belongs_to :activity, Activity

    timestamps()
  end

  @doc false
  def changeset(activity_lap, attrs) do
    activity_lap
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

defmodule Squeeze.Dashboard.Trackpoint do
  @moduledoc """
  This module holds trackpoint from an activity.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Dashboard.{TrackpointSet}

  @required_fields ~w()a
  @optional_fields ~w(altitude cadence coordinates distance heartrate time velocity)a

  schema "trackpoints" do
    field :altitude, :float
    field :cadence, :integer
    field :coordinates, :map
    field :distance, :float
    field :heartrate, :integer
    field :time, :integer
    field :velocity, :float

    belongs_to :trackpoint_set, TrackpointSet
  end

  @doc false
  def changeset(trackpoint, attrs) do
    trackpoint
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

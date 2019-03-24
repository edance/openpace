defmodule Squeeze.Races.Trackpoint do
  @moduledoc """
  This module holds track point for a race route.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Races.{Race}

  @required_fields ~w()a
  @optional_fields ~w(altitude coordinates distance)a

  schema "race_trackpoints" do
    field :altitude, :float
    field :coordinates, :map
    field :distance, :float

    belongs_to :race, Race
  end

  @doc false
  def changeset(trackpoint, attrs) do
    trackpoint
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

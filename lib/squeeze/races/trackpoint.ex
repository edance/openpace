defmodule Squeeze.Races.Trackpoint do
  @moduledoc false

  use Ecto.Schema

  # @required_fields ~w()a
  # @optional_fields ~w(altitude coordinates distance)a

  schema "race_trackpoints" do
    field :altitude, :float
    field :coordinates, :map
    field :distance, :float
  end
end

defmodule Squeeze.Races.Trackpoint do
  @moduledoc """
  This module holds track point for a race route.
  """

  use Ecto.Schema

  # @required_fields ~w()a
  # @optional_fields ~w(altitude coordinates distance)a

  schema "race_trackpoints" do
    field :altitude, :float
    field :coordinates, :map
    field :distance, :float
  end
end

defmodule Squeeze.Dashboard.Trackpoint do
  @moduledoc false

  use Ecto.Schema

  embedded_schema do
    field :altitude, :float
    field :cadence, :integer
    field :coordinates, :map
    field :distance, :float
    field :heartrate, :integer
    field :moving, :boolean
    field :time, :integer
    field :velocity, :float
  end
end

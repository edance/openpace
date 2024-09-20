defmodule Squeeze.Activities.Trackpoint do
  @moduledoc false

  use Ecto.Schema

  @derive {Jason.Encoder, except: []}

  embedded_schema do
    field :altitude, :float
    field :cadence, :integer
    field :coordinates, :map
    field :distance, :float
    field :grade_smooth, :float
    field :heartrate, :integer
    field :moving, :boolean
    field :temp, :integer
    field :time, :integer
    field :velocity, :float
    field :watts, :integer
  end
end

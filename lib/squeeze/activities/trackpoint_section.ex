defmodule Squeeze.Activities.TrackpointSection do
  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Activities.Activity

  schema "trackpoint_sections" do
    field :distance, :float
    field :duration, :integer
    field :velocity, :float

    belongs_to :activity, Activity
  end

  @doc false
  def changeset(trackpoint_section, attrs) do
    trackpoint_section
    |> cast(attrs, [:distance, :duration, :velocity])
    |> validate_required([:distance, :duration, :velocity])
  end
end

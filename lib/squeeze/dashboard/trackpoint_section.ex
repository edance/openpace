defmodule Squeeze.Dashboard.TrackpointSection do
  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Dashboard.Activity

  schema "trackpoint_sections" do
    field :distance, :float
    field :duration, :integer
    field :velocity, :float

    belongs_to :activity, Activity
  end

  @doc false
  def changeset(trackpoint_section, attrs) do
    trackpoint_section
    |> cast(attrs, [:velocity, :distance, :duration, :activity_id])
    |> validate_required([:velocity, :distance, :duration, :activity_id])
  end
end

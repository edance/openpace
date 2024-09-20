defmodule Squeeze.Activities.TrackpointSection do
  @moduledoc """
    TrackpointSection is a schema that represents a segment between two trackpoints.
    This is useful for calculating time or distance in pace zones.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Activities.Activity

  schema "trackpoint_sections" do
    field :distance, :float
    field :duration, :integer
    field :velocity, :float

    field :heartrate, :integer
    field :cadence, :integer
    field :power, :integer

    field :section_index, :integer

    belongs_to :activity, Activity
  end

  @doc false
  def changeset(trackpoint_section, attrs) do
    trackpoint_section
    |> cast(attrs, [
      :distance,
      :duration,
      :velocity,
      :heartrate,
      :cadence,
      :power,
      :section_index,
      :activity_id
    ])
    |> validate_required([:section_index])
  end
end

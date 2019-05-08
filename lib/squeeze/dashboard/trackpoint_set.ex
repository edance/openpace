defmodule Squeeze.Dashboard.TrackpointSet do
  @moduledoc """
  This module holds trackpoint from an activity.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Dashboard.{Activity, Trackpoint}

  @required_fields ~w()a
  @optional_fields ~w()a

  schema "trackpoint_sets" do
    belongs_to :activity, Activity

    has_many :trackpoints, Trackpoint

    timestamps()
  end

  @doc false
  def changeset(trackpoint, attrs \\ %{}) do
    trackpoint
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

defmodule Squeeze.Activities.TrackpointSet do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Activities.{Activity, Trackpoint}

  @required_fields ~w()a
  @optional_fields ~w()a

  schema "trackpoint_sets" do
    belongs_to :activity, Activity

    embeds_many :trackpoints, Trackpoint

    timestamps()
  end

  @doc false
  def changeset(trackpoint, attrs \\ %{}) do
    trackpoint
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

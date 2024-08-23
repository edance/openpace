defmodule Squeeze.Races.Event do
  @moduledoc false

  use Ecto.Schema

  alias Squeeze.Races.Race

  # @required_fields ~w(name slug city state country)a
  # @optional_fields ~w(content url)a

  schema "race_events" do
    field :name, :string
    field :details, :string

    field :start_at, :naive_datetime

    field :distance, :float
    field :distance_name, :string

    belongs_to :race, Race

    timestamps()
  end
end

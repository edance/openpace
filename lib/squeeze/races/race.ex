defmodule Squeeze.Races.Race do
  @moduledoc """
  This module contains the schema for the race.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(name slug city state country)a
  @optional_fields ~w(description url)a

  schema "races" do
    field :name, :string
    field :slug, :string
    field :overview, :string
    field :description, :string

    field :city, :string
    field :state, :string
    field :country, :string

    field :distance, :float
    field :distance_type, DistanceTypeEnum

    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(race, attrs) do
    race
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug)
  end
end

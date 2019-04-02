defmodule Squeeze.Races.Race do
  @moduledoc """
  This module contains the schema for the race.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Races.{Race, Trackpoint}

  @required_fields ~w(name slug city state country)a
  @optional_fields ~w(content url)a

  schema "races" do
    field :name, :string
    field :slug, :string
    field :content, :string

    field :address_line1, :string
    field :address_line2, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :postal_code, :string

    field :start_at, :naive_datetime
    field :timezone, :string

    field :distance, :float
    field :distance_type, DistanceTypeEnum

    field :url, :string

    has_many :trackpoints, Trackpoint

    timestamps()
  end

  @doc false
  def changeset(%Race{} = race, attrs) do
    race
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug)
  end
end

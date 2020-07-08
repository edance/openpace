defmodule Squeeze.Races.Race do
  @moduledoc """
  This module contains the schema for the race.
  """

  use Ecto.Schema

  alias Squeeze.Races.{Event, ResultSummary}

  # @required_fields ~w(name slug city state country)a
  # @optional_fields ~w(content url)a

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

    field :logo_url, :string

    field :start_date, :date

    field :active, :boolean
    field :boston_qualifier, :boolean
    field :certified, :boolean

    field :registration_url, :string
    field :url, :string

    field :course_profile, CourseProfileEnum
    field :course_terrain, CourseTerrainEnum
    field :course_type, CourseTypeEnum

    field :external_id, :string

    has_many :events, Event
    has_many :result_summaries, ResultSummary

    timestamps()
  end
end

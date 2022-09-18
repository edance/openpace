defmodule Squeeze.Races.Race do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.SlugGenerator
  alias Squeeze.Races.{Event, Race, RaceGoal, ResultSummary}

  @required_fields ~w(
    name
    start_date
  )a

  @optional_fields ~w(
    city
    state
    country
    content
    url
  )a

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

    field :distance, :float

    field :active, :boolean
    field :boston_qualifier, :boolean
    field :certified, :boolean

    field :registration_url, :string
    field :url, :string

    field :course_profile, Ecto.Enum, values: [unknown: 0, downhill: 1, flat: 2, rolling_hills: 3, hilly: 4]
    field :course_terrain, Ecto.Enum, values: [unknown: 0, road: 1, trail: 2]
    field :course_type, Ecto.Enum, values: [unknown: 0, loop: 1, out_and_back: 2, point_to_point: 3]

    field :external_id, :string

    has_many :events, Event
    has_many :result_summaries, ResultSummary
    has_many :race_goals, RaceGoal

    timestamps()
  end

  @doc false
  def changeset(%Race{} = race, attrs) do
    race
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> put_change(:slug, SlugGenerator.gen_slug())
    |> validate_required(@required_fields)
  end
end

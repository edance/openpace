defmodule Squeeze.Dashboard.Activity do
  @moduledoc """
  This module contains the schema for the activity. Activities are pulled from
  different services.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, Event}

  @required_fields ~w(name)a
  @optional_fields ~w(
    planned_distance
    planned_duration
    planned_date
    distance
    start_at
    duration
    external_id
    polyline
    event_id
  )a

  schema "activities" do
    field :name, :string

    # Planning Fields
    field :planned_distance, :float
    field :planned_duration, :integer
    field :planned_date, :date

    # Fields for after activity is completed
    field :distance, :float
    field :duration, :integer
    field :start_at, :naive_datetime
    field :polyline, :string
    field :external_id, :integer

    field :complete, :boolean

    belongs_to :user, User
    belongs_to :event, Event

    timestamps()
  end

  @doc false
  def changeset(%Activity{} = activity, attrs) do
    activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

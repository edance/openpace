defmodule Squeeze.Dashboard.Activity do
  @moduledoc """
  This module contains the schema for the activity. Activities are pulled from
  different services.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, Event}

  @required_fields ~w(name distance start_at)a
  @optional_fields ~w(duration external_id polyline event_id)a

  schema "activities" do
    field :distance, :float
    field :duration, :integer
    field :name, :string
    field :polyline, :string
    field :start_at, :naive_datetime
    field :external_id, :integer

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

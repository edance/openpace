defmodule Squeeze.Dashboard.Activity do
  @moduledoc """
  This module contains the schema for the activity. Activities are pulled from
  different services.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Activity

  @required_fields ~w(name distance duration start_at external_id)a
  @optional_fields ~w(polyline)a

  schema "activities" do
    field :distance, :float
    field :duration, Squeeze.Duration
    field :name, :string
    field :polyline, :string
    field :start_at, :naive_datetime
    field :external_id, :integer

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Activity{} = activity, attrs) do
    activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

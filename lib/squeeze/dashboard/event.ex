defmodule Squeeze.Dashboard.Event do
  use Ecto.Schema

  @moduledoc """
  This module is the schema for an event in the database.
  """

  import Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Event

  schema "events" do
    field :cooldown, :boolean, default: false
    field :date, :date
    field :distance, :float
    field :name, :string
    field :warmup, :boolean, default: false

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, [:name, :distance, :date, :warmup, :cooldown])
    |> validate_required([:distance, :date])
  end
end

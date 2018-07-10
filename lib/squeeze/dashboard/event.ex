defmodule Squeeze.Dashboard.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Dashboard.{Event, Pace}
  alias Squeeze.Accounts.User


  schema "events" do
    field :cooldown, :boolean, default: false
    field :date, :date
    field :distance, :float
    field :name, :string
    field :warmup, :boolean, default: false

    belongs_to :pace, Pace
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, [:name, :distance, :date, :warmup, :cooldown, :pace_id])
    |> validate_required([:distance, :date])
  end
end

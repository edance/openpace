defmodule Squeeze.Dashboard.Activity do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Accounts.User


  schema "activities" do
    field :distance, :float
    field :duration, Squeeze.Duration
    field :name, :string
    field :start_at, :naive_datetime
    field :external_id, :integer

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Activity{} = activity, attrs) do
    activity
    |> cast(attrs, [:name, :distance, :duration, :start_at, :external_id])
    |> validate_required([:name, :distance, :duration, :start_at, :external_id])
  end
end

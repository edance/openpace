defmodule Squeeze.Dashboard.Activity do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Dashboard.Activity


  schema "activities" do
    field :distance, :float
    field :duration, :integer
    field :name, :string
    field :start_at, :naive_datetime
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Activity{} = activity, attrs) do
    activity
    |> cast(attrs, [:name, :distance, :duration, :start_at])
    |> validate_required([:name, :distance, :duration, :start_at])
  end
end

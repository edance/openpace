defmodule Squeeze.Dashboard.Goal do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Dashboard.Goal
  alias Squeeze.Accounts.User


  schema "goals" do
    field :date, :date
    field :distance, :float
    field :duration, :integer
    field :name, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Goal{} = goal, attrs) do
    goal
    |> cast(attrs, [:distance, :duration, :name, :date])
    |> validate_required([:distance, :duration])
  end
end

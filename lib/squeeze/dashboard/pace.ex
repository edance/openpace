defmodule Squeeze.Dashboard.Pace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Dashboard.Pace
  alias Squeeze.Accounts.User


  schema "paces" do
    field :name, :string
    field :offset, :integer

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Pace{} = pace, attrs) do
    pace
    |> cast(attrs, [:name, :offset])
    |> validate_required([:name, :offset])
  end
end

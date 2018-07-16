defmodule Squeeze.Dashboard.Pace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Dashboard.Pace
  alias Squeeze.Accounts.User


  schema "paces" do
    field :name, :string
    field :offset, :integer
    field :color, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Pace{} = pace, attrs) do
    pace
    |> cast(attrs, [:name, :offset, :color])
    |> validate_required([:name, :offset])
    |> validate_format(:color, ~r/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
  end
end

defmodule Fitbit.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitbit.Accounts.{User, Credential}


  schema "users" do
    field :name, :string
    field :description, :string
    field :image, :string
    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :description, :image])
    |> validate_required([:name])
  end
end

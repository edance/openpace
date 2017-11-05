defmodule Squeeze.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User, Credential}

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :description, :string
    field :avatar, :string
    field :city, :string
    field :state, :string
    field :country, :string

    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    fields = ~w(first_name last_name description avatar city state country)a
    user
    |> cast(attrs, fields)
    |> validate_required([:first_name, :last_name])
  end
end

defmodule Squeeze.Accounts.User do
  @moduledoc """
  This module is the schema for the user in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{Credential, User, UserPrefs}

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :description, :string
    field :avatar, :string
    field :city, :string
    field :state, :string
    field :country, :string

    has_one :credential, Credential
    has_one :user_prefs, UserPrefs

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    fields = ~w(first_name last_name email description avatar city state country)a
    user
    |> cast(attrs, fields)
    |> validate_format(:email, ~r/@/)
  end
end

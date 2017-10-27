defmodule Squeeze.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{Credential, User}


  schema "credentials" do
    field :provider, :string
    field :token, :string
    field :uid, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:provider, :uid, :token])
    |> validate_required([:provider, :uid, :token])
  end
end

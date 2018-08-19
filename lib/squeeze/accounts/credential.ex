defmodule Squeeze.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{Credential, User}


  schema "credentials" do
    field :provider, :string
    field :token, :string
    field :uid, :integer
    field :sync_at, :utc_datetime

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:provider, :uid, :token, :sync_at])
    |> validate_required([:provider, :uid, :token])
  end
end

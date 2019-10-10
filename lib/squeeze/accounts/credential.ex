defmodule Squeeze.Accounts.Credential do
  use Ecto.Schema

  @moduledoc """
  This is a module that holds the token for different ways to connect.
  Currently strava is the only way to connect. This also holds data about when
  the last sync was.
  """

  import Ecto.Changeset
  alias Squeeze.Accounts.{Credential, User}

  @required_fields ~w(provider uid)a
  @optional_fields ~w(
    token
    token_secret
    access_token
    refresh_token
    sync_at
  )a

  schema "credentials" do
    field :provider, :string
    field :uid, :string
    field :sync_at, :utc_datetime

    # OAuth 1.0
    field :token, :string
    field :token_secret, :string

    # OAuth 2.0
    field :access_token, :string
    field :refresh_token, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:unique_credential, name: :credentials_uid_provider_index)
  end
end

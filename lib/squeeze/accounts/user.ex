defmodule Squeeze.Accounts.User do
  @moduledoc """
  This module is the schema for the user in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Comeonin.Argon2
  alias Squeeze.Accounts.{Credential, User, UserPrefs}

  @registration_fields ~w(email encrypted_password)a

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :description, :string
    field :avatar, :string
    field :city, :string
    field :state, :string
    field :country, :string

    field :registered, :boolean

    field :encrypted_password, :string

    field :stripe_customer_id, :string

    has_one :credential, Credential
    has_one :user_prefs, UserPrefs

    timestamps()
  end

  def full_name(%User{first_name: first_name, last_name: nil}), do: first_name
  def full_name(%User{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  def improvement_amount(%User{user_prefs: %{personal_record: nil}}), do: nil
  def improvement_amount(%User{user_prefs: prefs}) do
    duration = prefs.duration
    percent = abs(prefs.personal_record - prefs.duration) / duration * 100
    "#{Decimal.round(Decimal.new(percent), 1)}%"
  end

  def onboarded?(%User{} = user) do
    UserPrefs.complete?(user.user_prefs)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    fields = ~w(first_name last_name email description avatar city state country)a
    user
    |> cast(attrs, fields)
    |> validate_format(:email, ~r/@/)
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @registration_fields)
    |> validate_required(@registration_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:encrypted_password, min: 8)
    |> put_change(:registered, true)
    |> encrypt_password()
  end

  defp encrypt_password(changeset) do
    update_change(changeset, :encrypted_password, &Argon2.hashpwsalt/1)
  end
end

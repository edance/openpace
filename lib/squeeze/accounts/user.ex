defmodule Squeeze.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.{Credential, User, UserPrefs}
  alias Squeeze.Challenges.{Score}

  @registration_fields ~w(first_name last_name email encrypted_password)a
  @payment_processor_fields ~w(customer_id subscription_id subscription_status trial_end)a

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :description, :string
    field :avatar, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :slug, :string
    field :follower_count, :integer
    field :following_count, :integer

    field :registered, :boolean

    field :encrypted_password, :string

    field :customer_id, :string
    field :subscription_id, :string
    field :subscription_status, Ecto.Enum, values: [incomplete: 0, incomplete_expired: 1, trialing: 2, active: 3, past_due: 4, canceled: 5, unpaid: 6, free: 7]
    field :trial_end, :utc_datetime

    has_many :credentials, Credential
    has_many :scores, Score

    has_one :user_prefs, UserPrefs

    timestamps()
  end

  def full_name(%User{first_name: first_name, last_name: nil}), do: first_name

  def full_name(%User{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    fields = ~w(first_name last_name email description avatar city state country)a

    user
    |> cast(attrs, fields)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:first_name, max: 50)
    |> validate_length(:last_name, max: 50)
    |> put_registered()
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, @registration_fields)
    |> validate_required(@registration_fields)
    |> validate_length(:encrypted_password, min: 8)
    |> encrypt_password()
  end

  @doc false
  def password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:encrypted_password])
    |> validate_required([:encrypted_password])
    |> validate_length(:encrypted_password, min: 8)
    |> encrypt_password()
  end

  def payment_processor_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @payment_processor_fields)
    |> validate_required([:customer_id])
  end

  defp put_registered(changeset) do
    email = get_field(changeset, :email)
    put_change(changeset, :registered, !is_nil(email))
  end

  defp encrypt_password(changeset) do
    update_change(changeset, :encrypted_password, &Argon2.hash_pwd_salt/1)
  end
end

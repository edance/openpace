defmodule Squeeze.Accounts.UserPrefs do
  @moduledoc """
  This module is the schema for the user preferences.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{PersonalRecord, User, UserPrefs}

  @required_fields ~w()a
  @optional_fields ~w(
    experience
    timezone
    imperial
    gender
    birthdate
    rename_activities
    emoji
    branding
  )a

  schema "user_prefs" do
    field :experience, :integer
    field :timezone, :string
    field :imperial, :boolean
    field :gender, Ecto.Enum, values: [male: 0, female: 1, other: 2, prefer_not_to_say: 3]
    field :birthdate, :date

    # Namer Fields
    field :rename_activities, :boolean
    field :emoji, :boolean
    field :branding, :boolean

    embeds_many :personal_records, PersonalRecord, on_replace: :delete

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%UserPrefs{} = user_prefs, %{"personal_records" => _prs} = attrs) do
    user_prefs
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_embed(:personal_records, with: &PersonalRecord.changeset/2)
    |> validate_required(@required_fields)
  end
  def changeset(%UserPrefs{} = user_prefs, attrs) do
    user_prefs
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

defmodule Squeeze.Accounts.UserPrefs do
  @moduledoc """
  This module is the schema for the user preferences that are collected with
  onboarding.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User, UserPrefs}
  alias Squeeze.Duration

  @required_fields ~w()a
  @non_empty_fields ~w(distance)a
  @optional_fields ~w(
    distance
    duration
    personal_record
    race_date
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
    field :distance, :integer
    field :duration, Duration
    field :personal_record, Duration
    field :race_date, :date
    field :experience, :integer
    field :timezone, :string
    field :imperial, :boolean
    field :gender, Ecto.Enum, values: [male: 0, female: 1, other: 2, prefer_not_to_say: 3]
    field :birthdate, :date

    # Namer Fields
    field :rename_activities, :boolean
    field :emoji, :boolean
    field :branding, :boolean

    belongs_to :user, User

    timestamps()
  end

  def complete?(%UserPrefs{} = user_prefs) do
    !is_nil(user_prefs.distance) &&
      !is_nil(user_prefs.duration) &&
      !is_nil(user_prefs.personal_record) &&
      !is_nil(user_prefs.race_date)
  end

  @doc false
  def changeset(%UserPrefs{} = user_prefs, attrs) do
    fields = attrs
    |> Map.keys()
    |> Enum.map(fn(x) -> is_atom(x) && x || String.to_atom(x) end)
    |> Enum.filter(&Enum.member?(@non_empty_fields, &1))

    user_prefs
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields ++ fields)
  end
end

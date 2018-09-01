defmodule Squeeze.Accounts.UserPrefs do
  @moduledoc """
  This module is the schema for the user preferences that are collected with
  onboarding.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User, UserPrefs}

  @required_fields ~w()a
  @optional_fields ~w(distance duration personal_record name race_date experience)a

  schema "user_prefs" do
    field :distance, :integer
    field :duration, Squeeze.Duration
    field :name, :string
    field :personal_record, Squeeze.Duration
    field :race_date, :date
    field :experience, :integer

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
    user_prefs
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

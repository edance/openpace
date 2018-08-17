defmodule Squeeze.Accounts.UserPrefs do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User, UserPrefs}

  schema "user_prefs" do
    field :distance, :float
    field :duration, Squeeze.Duration
    field :name, :string
    field :personal_record, Squeeze.Duration
    field :race_date, :date
    field :experience, :integer

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%UserPrefs{} = user_prefs, attrs) do
    user_prefs
    |> cast(attrs, [:distance, :duration, :personal_record, :name, :race_date, :experience])
  end
end

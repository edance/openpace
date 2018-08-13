defmodule Squeeze.Accounts.UserPrefs do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User, UserPrefs}

  schema "user_prefs" do
    field :distance, :float
    field :duration, Squeeze.Duration
    field :name, :string
    field :personal_record, :integer
    field :race_date, :date

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%UserPrefs{} = user_prefs, attrs) do
    user_prefs
    |> cast(attrs, [:distance, :duration, :personal_record, :name, :race_date])
  end
end

defmodule Squeeze.Races.RaceGoal do
  @moduledoc """
  This defines the goals for a user for a given race.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User
  alias Squeeze.Duration
  alias Squeeze.Races.{Race, RaceGoal}

  @required_fields ~w()a
  @optional_fields ~w(duration just_finish)a

  schema "race_goals" do
    field :duration, Duration
    field :just_finish, :boolean

    belongs_to :user, User
    belongs_to :race, Race

    timestamps()
  end

  def changeset(%RaceGoal{} = race_goal, attrs) do
    race_goal
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

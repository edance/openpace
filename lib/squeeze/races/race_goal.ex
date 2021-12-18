defmodule Squeeze.Races.RaceGoal do
  @moduledoc """
  This defines the goals for a user for a given race.
  """

  use Ecto.Schema

  alias Squeeze.Accounts.User
  alias Squeeze.Duration
  alias Squeeze.Races.Race

  # @required_fields ~w(name slug city state country)a
  # @optional_fields ~w(content url)a

  schema "race_goals" do
    field :duration, Duration
    field :just_finish, :boolean

    belongs_to :user, User
    belongs_to :race, Race

    timestamps()
  end
end

defmodule Squeeze.Races.RaceGoal do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User
  alias Squeeze.Activities.{Activity}
  alias Squeeze.Duration
  alias Squeeze.Races.{TrainingPace, Race, RaceGoal}

  @required_fields ~w(
    distance
    race_date
    race_name
  )a
  @optional_fields ~w(
    duration
    just_finish
  )a

  schema "race_goals" do
    field :race_name, :string
    field :slug, :string
    field :race_date, :date
    field :distance, :float
    field :duration, Duration
    field :just_finish, :boolean

    embeds_many :training_paces, TrainingPace

    belongs_to :activity, Activity
    belongs_to :user, User
    belongs_to :race, Race

    timestamps()
  end

  def changeset(%RaceGoal{} = race_goal, attrs) do
    race_goal
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:activity_id)
  end
end

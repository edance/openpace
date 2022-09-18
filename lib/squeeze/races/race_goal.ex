defmodule Squeeze.Races.RaceGoal do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User
  alias Squeeze.Duration
  alias Squeeze.Races.{TrainingPace, Race, RaceGoal}
  alias Squeeze.SlugGenerator

  @required_fields ~w(distance)a
  @optional_fields ~w(duration just_finish)a

  schema "race_goals" do
    field :slug, :string
    field :distance, :float
    field :duration, Duration
    field :just_finish, :boolean

    embeds_many :training_paces, TrainingPace

    belongs_to :user, User
    belongs_to :race, Race

    timestamps()
  end

  def changeset(%RaceGoal{} = race_goal, attrs) do
    race_goal
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> put_change(:slug, SlugGenerator.gen_slug())
    |> validate_required(@required_fields)
  end
end

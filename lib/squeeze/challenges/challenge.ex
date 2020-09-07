defmodule Squeeze.Challenges.Challenge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User}

  @required_fields ~w(
    activity_type
    challenge_type
    timeline
  )a
  @optional_fields ~w(
    name
    start_at
    end_at
  )a

  schema "challenges" do
    field :activity_type, ActivityTypeEnum
    field :challenge_type, ChallengeTypeEnum
    field :end_at, :naive_datetime
    field :name, :string
    field :start_at, :naive_datetime
    field :timeline, TimelineEnum

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

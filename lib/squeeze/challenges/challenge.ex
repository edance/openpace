defmodule Squeeze.Challenges.Challenge do
  @moduledoc """
  This module is the schema for challenges in the database.
  """

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
    many_to_many :users, User, join_through: "user_challenge", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

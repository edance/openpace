defmodule Squeeze.Challenges.Challenge do
  @moduledoc """
  This module is the schema for challenges in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User}
  alias Squeeze.Challenges.{Score}

  @required_fields ~w(
    name
    activity_type
    challenge_type
    timeline
    start_at
    end_at
  )a
  @optional_fields ~w(
    segment_id
    polyline
  )a

  schema "challenges" do
    field :activity_type, ActivityTypeEnum
    field :challenge_type, ChallengeTypeEnum
    field :end_at, :utc_datetime
    field :name, :string
    field :start_at, :utc_datetime
    field :timeline, TimelineEnum
    field :private, :boolean
    field :slug, :string
    field :segment_id, Squeeze.Stringable
    field :polyline, :string

    belongs_to :user, User
    has_many :scores, Score
    many_to_many :users, User, join_through: "scores", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:slug)
  end

  def add_user_changeset(challenge, %User{} = user) do
    challenge
    |> put_assoc(:users, [user])
  end
end

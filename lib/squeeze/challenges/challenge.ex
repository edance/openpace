defmodule Squeeze.Challenges.Challenge do
  @moduledoc """
  This module is the schema for challenges in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User}
  alias Squeeze.Challenges.{ChallengeActivity, Score}

  @required_fields ~w(
    name
    activity_type
    challenge_type
    start_date
    end_date
  )a
  @segment_required_fields ~w(
    segment_id
    polyline
  )a
  @optional_fields ~w(
    timeline
    private
    recurring
  )a

  schema "challenges" do
    field :activity_type, ActivityTypeEnum
    field :challenge_type, ChallengeTypeEnum
    field :start_date, :date # starts at 00:00 on start_date
    field :end_date, :date # ends at 11:59 on end_date
    field :name, :string
    field :timeline, TimelineEnum
    field :private, :boolean
    field :recurring, :boolean
    field :slug, :string
    field :segment_id, Squeeze.Stringable
    field :polyline, :string

    belongs_to :user, User
    has_many :scores, Score
    has_many :challenge_activities, ChallengeActivity, on_replace: :delete
    many_to_many :users, User, join_through: "scores", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required_fields ++ @optional_fields ++ @segment_required_fields)
    |> validate_required(@required_fields)
    |> validate_segment_type()
    |> unique_constraint(:slug)
  end

  def add_user_changeset(challenge, %User{} = user) do
    challenge
    |> put_assoc(:users, [user])
  end

  defp validate_segment_type(changeset) do
    case get_field(changeset, :challenge_type) do
      :segment -> validate_required(changeset, @segment_required_fields)
      _ -> changeset
    end
  end
end

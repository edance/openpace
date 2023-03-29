defmodule Squeeze.Challenges.ChallengeActivity do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Challenges.Challenge
  alias Squeeze.Activities.Activity

  @required_fields ~w(amount)a
  @optional_fields ~w()a

  schema "challenge_activities" do
    field :amount, :float

    belongs_to :activity, Activity
    belongs_to :challenge, Challenge

    timestamps()
  end

  @doc false
  def changeset(challenge_activity, attrs \\ %{}) do
    challenge_activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

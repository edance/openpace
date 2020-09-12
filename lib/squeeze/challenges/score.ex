defmodule Squeeze.Challenges.Score do
  @moduledoc """
  This module keeps score of the challenge and builds the leaderboard.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User
  alias Squeeze.Challenges.Challenge

  schema "scores" do
    field :score, :integer

    belongs_to :user, User
    belongs_to :challenge, Challenge

    timestamps()
  end

  @doc false
  def changeset(score, attrs \\ %{}) do
    score
    |> cast(attrs, [:score])
  end
end

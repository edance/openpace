defmodule Squeeze.Challenges.Score do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User
  alias Squeeze.Challenges.Challenge

  schema "scores" do
    field :amount, :float

    # Used for ranking only and not visible to the user
    field :score, :float

    belongs_to :user, User
    belongs_to :challenge, Challenge

    timestamps()
  end

  @doc false
  def changeset(score, attrs \\ %{}) do
    score
    |> cast(attrs, [:amount])
    |> unique_constraint(:user,
      name: :scores_user_id_challenge_id_index,
      message: "already joined"
    )
  end
end

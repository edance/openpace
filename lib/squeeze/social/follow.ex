defmodule Squeeze.Social.Follow do
  @moduledoc """
  This module is a schema for follows
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User

  @required_fields ~w()a
  @optional_fields ~w(pending)a

  schema "follows" do
    field :pending, :boolean

    belongs_to :follower, User
    belongs_to :followee, User

    timestamps()
  end

  @doc false
  def changeset(follow, attrs \\ %{}) do
    follow
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:unique_follow, name: :follows_follower_id_followee_id_index)
  end
end

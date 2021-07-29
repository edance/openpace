defmodule Squeeze.Social.Follower do
  @moduledoc """
  This module is a schema for followers
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.{User}

  schema "followers" do
    field :pending, :boolean

    belongs_to :user, User
    belongs_to :follows, User

    timestamps()
  end

  @doc false
  def changeset(follower, attrs) do
    follower
    |> cast(attrs, [])
    |> validate_required([])
  end
end

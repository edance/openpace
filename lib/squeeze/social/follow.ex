defmodule Squeeze.Social.Follow do
  @moduledoc """
  This module is a schema for follows
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.{User}

  schema "follows" do
    field :pending, :boolean

    belongs_to :user, User
    belongs_to :follows, User

    timestamps()
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [])
    |> validate_required([])
  end
end

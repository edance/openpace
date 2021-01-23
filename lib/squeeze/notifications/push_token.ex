defmodule Squeeze.Notifications.PushToken do
  @moduledoc """
  This module is the schema for push tokens to send notifications to physical devices.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User}

  schema "push_tokens" do
    field :token, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(push_token, attrs) do
    push_token
    |> cast(attrs, [:token])
    |> validate_required([:token])
    |> unique_constraint(:unique_token, name: :push_tokens_user_id_token_index)
  end
end

defmodule Squeeze.MailingList.Subscription do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :email, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:email, :type])
    |> validate_format(:email, ~r/@/)
    |> validate_required([:email, :type])
  end
end

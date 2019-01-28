defmodule Squeeze.Billing.PaymentMethod do
  @moduledoc """
  This module contains the schema for stripe payment methods.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User

  schema "payment_methods" do
    field :exp_month, :integer
    field :exp_year, :integer
    field :last4, :string
    field :name, :string
    field :stripe_id, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(payment_method, attrs) do
    payment_method
    |> cast(attrs, [:name, :stripe_id, :last4, :exp_month, :exp_year])
    |> validate_required([:name, :stripe_id, :last4, :exp_month, :exp_year])
  end
end

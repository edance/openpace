defmodule Squeeze.Billing.PaymentMethod do
  @moduledoc """
  This module contains the schema for stripe payment methods.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User

  schema "payment_methods" do
    # Billing Information
    field :owner_name, :string
    field :address_city, :string
    field :address_country, :string
    field :address_line1, :string
    field :address_line2, :string
    field :address_state, :string
    field :address_zip, :string

    # Card Information
    field :name, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :last4, :string
    field :stripe_id, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(payment_method, attrs) do
    payment_method
    |> cast(attrs, [:owner_name, :stripe_id, :last4, :exp_month, :exp_year])
    |> validate_required([:owner_name, :stripe_id, :last4, :exp_month, :exp_year])
  end
end

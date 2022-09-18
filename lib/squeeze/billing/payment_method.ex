defmodule Squeeze.Billing.PaymentMethod do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User

  @required_fields ~w(
    owner_name
    address_zip
    exp_month
    exp_year
    last4
    stripe_id
  )a

  schema "payment_methods" do
    # Billing Information
    field :owner_name, :string
    field :address_zip, :string

    # Card Information
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
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end

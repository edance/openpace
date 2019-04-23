defmodule Squeeze.Billing.Invoice do
  @moduledoc """
  This module contains the schema for the billing plans.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User

  @required_fields ~w(name amount_due provider_id status)a
  @optional_fields ~w()

  schema "billing_plans" do
    field :name, :string
    field :amount_due, :integer
    field :provider_id, :string
    field :status, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

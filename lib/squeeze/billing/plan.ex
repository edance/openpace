defmodule Squeeze.Billing.Plan do
  @moduledoc """
  This module contains the schema for the billing plans.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(name amount provider_id interval)a
  @optional_fields ~w()a

  schema "billing_plans" do
    field :name, :string
    field :amount, :integer
    field :provider_id, :string
    field :interval, :string

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

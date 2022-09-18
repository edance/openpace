defmodule Squeeze.Billing.Invoice do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User

  @required_fields ~w(name amount_due due_date provider_id status)a
  @optional_fields ~w()

  schema "billing_invoices" do
    field :name, :string
    field :amount_due, :integer
    field :provider_id, :string
    field :status, :string
    field :due_date, :utc_datetime

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

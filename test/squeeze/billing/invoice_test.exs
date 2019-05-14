defmodule Squeeze.Accounts.InvoiceTest do
  use Squeeze.DataCase

  alias Squeeze.Billing.Invoice

  import Squeeze.Factory

  @valid_attrs params_for(:invoice)

  test "changeset with full attributes" do
    changeset = Invoice.changeset(%Invoice{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = Invoice.changeset(%Invoice{}, %{})
    refute changeset.valid?
  end
end

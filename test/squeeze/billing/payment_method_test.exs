defmodule Squeeze.Accounts.PaymentMethodTest do
  use Squeeze.DataCase

  alias Squeeze.Billing.PaymentMethod

  import Squeeze.Factory

  @valid_attrs params_for(:payment_method)

  test "changeset with full attributes" do
    changeset = PaymentMethod.changeset(%PaymentMethod{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = PaymentMethod.changeset(%PaymentMethod{}, %{})
    refute changeset.valid?
  end
end

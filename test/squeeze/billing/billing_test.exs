defmodule Squeeze.BillingTest do
  use Squeeze.DataCase

  alias Squeeze.Billing

  describe "payment_methods" do
    alias Squeeze.Billing.PaymentMethod

    @valid_attrs %{exp_month: 42, exp_year: 42, last4: "some last4", name: "some name", stripe_id: "some stripe_id"}
    @update_attrs %{exp_month: 43, exp_year: 43, last4: "some updated last4", name: "some updated name", stripe_id: "some updated stripe_id"}
    @invalid_attrs %{exp_month: nil, exp_year: nil, last4: nil, name: nil, stripe_id: nil}

    def payment_method_fixture(attrs \\ %{}) do
      {:ok, payment_method} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Billing.create_payment_method()

      payment_method
    end

    test "list_payment_methods/0 returns all payment_methods" do
      payment_method = payment_method_fixture()
      assert Billing.list_payment_methods() == [payment_method]
    end

    test "get_payment_method!/1 returns the payment_method with given id" do
      payment_method = payment_method_fixture()
      assert Billing.get_payment_method!(payment_method.id) == payment_method
    end

    test "create_payment_method/1 with valid data creates a payment_method" do
      assert {:ok, %PaymentMethod{} = payment_method} = Billing.create_payment_method(@valid_attrs)
      assert payment_method.exp_month == 42
      assert payment_method.exp_year == 42
      assert payment_method.last4 == "some last4"
      assert payment_method.name == "some name"
      assert payment_method.stripe_id == "some stripe_id"
    end

    test "create_payment_method/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_payment_method(@invalid_attrs)
    end

    test "update_payment_method/2 with valid data updates the payment_method" do
      payment_method = payment_method_fixture()
      assert {:ok, payment_method} = Billing.update_payment_method(payment_method, @update_attrs)
      assert %PaymentMethod{} = payment_method
      assert payment_method.exp_month == 43
      assert payment_method.exp_year == 43
      assert payment_method.last4 == "some updated last4"
      assert payment_method.name == "some updated name"
      assert payment_method.stripe_id == "some updated stripe_id"
    end

    test "update_payment_method/2 with invalid data returns error changeset" do
      payment_method = payment_method_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_payment_method(payment_method, @invalid_attrs)
      assert payment_method == Billing.get_payment_method!(payment_method.id)
    end

    test "delete_payment_method/1 deletes the payment_method" do
      payment_method = payment_method_fixture()
      assert {:ok, %PaymentMethod{}} = Billing.delete_payment_method(payment_method)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_payment_method!(payment_method.id) end
    end

    test "change_payment_method/1 returns a payment_method changeset" do
      payment_method = payment_method_fixture()
      assert %Ecto.Changeset{} = Billing.change_payment_method(payment_method)
    end
  end
end

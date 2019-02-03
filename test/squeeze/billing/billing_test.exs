defmodule Squeeze.BillingTest do
  use Squeeze.DataCase

  alias Squeeze.Billing
  alias Squeeze.Billing.PaymentMethod

  import Squeeze.Factory

  describe "get_default_payment_method/1" do
    test "includes only the users payment_method" do
      [payment_method, _] = insert_pair(:payment_method)

      default_method = Billing.get_default_payment_method(payment_method.user)
      assert default_method.id == payment_method.id
    end

    test "returns only the latest payment_method" do
      method_1 = insert(:payment_method)
      user = method_1.user
      method_2 = insert(:payment_method, user: user)
      default_method = Billing.get_default_payment_method(user)
      assert default_method.id == method_2.id
    end
  end

  describe "get_payment_method!/2" do
    setup [:create_payment_method]

    test "returns the payment_method if found",
      %{payment_method: payment_method, user: user} do
      assert payment_method.id ==
        Billing.get_payment_method!(user, payment_method.id).id
    end

    test "raises error if payment_method does not belong to user",
      %{payment_method: payment_method} do
      user = insert(:user)
      assert_raise Ecto.NoResultsError, fn ->
        Billing.get_payment_method!(user, payment_method.id) end
    end

    test "raises error if payment_method does not exist", %{user: user} do
      assert_raise Ecto.NoResultsError, fn ->
        Billing.get_payment_method!(user, "1234") end
    end
  end

  describe "create_payment_method/2" do
    setup [:create_user]

    test "with valid attrs creates a payment_method", %{user: user} do
      attrs = params_for(:payment_method)
      assert {:ok, payment_method} = Billing.create_payment_method(user, attrs)
      assert payment_method.user_id == user.id
    end

    test "with invalid attrs returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Billing.create_payment_method(user, %{})
    end
  end

  describe "update_payment_method/2" do
    setup [:create_payment_method]

    test "with valid attrs updates the payment method",
      %{payment_method: payment_method} do
      attrs = %{owner_name: "some updated name"}
      assert {:ok, payment_method} =
        Billing.update_payment_method(payment_method, attrs)
      assert payment_method.owner_name == "some updated name"
    end

    test "with invalid attrs returns error changeset",
      %{payment_method: payment_method} do
      assert {:error, %Ecto.Changeset{}} =
        Billing.update_payment_method(payment_method, %{stripe_id: nil})
    end

    test "cannot update the user_id", %{payment_method: payment_method} do
      user = insert(:user)
      attrs = %{user_id: user.id}
      assert {:ok, payment_method} =
        Billing.update_payment_method(payment_method, attrs)
      refute payment_method.user_id == user.id
    end
  end

  test "delete_payment_method/1 deletes the payment_method" do
    payment_method = insert(:payment_method)
    user = payment_method.user

    assert {:ok, %PaymentMethod{}} =
      Billing.delete_payment_method(payment_method)
    assert_raise Ecto.NoResultsError, fn ->
      Billing.get_payment_method!(user, payment_method.id) end
  end

  test "change_payment_method/1 returns a payment_method changeset" do
    payment_method = build(:payment_method)
    assert %Ecto.Changeset{} = Billing.change_payment_method(payment_method)
  end

  defp create_user(_) do
    {:ok, user: insert(:user)}
  end

  defp create_payment_method(_) do
    payment_method = insert(:payment_method)
    {:ok, payment_method: payment_method, user: payment_method.user}
  end
end

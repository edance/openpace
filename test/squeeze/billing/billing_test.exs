defmodule Squeeze.BillingTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts
  alias Squeeze.Billing
  alias Squeeze.Billing.PaymentMethod

  import Mox
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

  describe "start_free_trial/1" do
    setup [:create_user, :mock_create_customer, :mock_create_subscription]

    test "with a default billing plan", %{user: user} do
      insert(:billing_plan, default: true)
      {:ok, user} = Billing.start_free_trial(user)
      refute is_nil(user.customer_id)
      refute is_nil(user.subscription_id)
    end

    test "without a default billing plan", %{user: user} do
      {:ok, user} = Billing.start_free_trial(user)
      refute is_nil(user.customer_id)
      assert is_nil(user.subscription_id)
    end
  end

  describe "update_subscription_status/1" do
    test "with a valid subscription and status" do
      %{subscription_id: id} = insert(:paid_user)
      attrs = %{id: id, status: :canceled}
      {:ok, user} = Billing.update_subscription_status(attrs)
      assert user.subscription_status == :canceled
    end

    test "with an invalid subscription" do
      attrs = %{id: "sub_12345", status: :canceled}
      assert {:error} = Billing.update_subscription_status(attrs)
    end

    test "with an invalid status" do
      %{subscription_id: id} = insert(:paid_user)
      attrs = %{id: id, status: :something}
      assert {:error, _} = Billing.update_subscription_status(attrs)
    end
  end

  describe "update_payment_method/1" do
    test "with a user updates the subscription_status" do
      user = insert(:paid_user)
      attrs = %{id: user.subscription_id, status: "unpaid"}
      assert {:ok, _} = Billing.update_subscription_status(attrs)
      assert Accounts.get_user!(user.id).subscription_status == :unpaid
    end

    test "without a user returns error" do
      attrs = %{id: "12345", status: "active"}
      assert {:error} = Billing.update_subscription_status(attrs)
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

  describe "billing_plans" do
    alias Squeeze.Billing.Plan

    test "list_billing_plans/0 returns all billing_plans" do
      plan = insert(:billing_plan)
      assert Billing.list_billing_plans() == [plan]
    end

    test "get_plan!/1 returns the plan with given id" do
      plan = insert(:billing_plan)
      assert Billing.get_plan!(plan.id) == plan
    end

    test "create_plan/1 with valid data creates a plan" do
      attrs = params_for(:billing_plan, name: "some name")
      assert {:ok, %Plan{} = plan} = Billing.create_plan(attrs)
      assert plan.name == "some name"
    end

    test "create_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_plan(%{})
    end
  end

  defp mock_create_customer(_) do
    customer = %{id: "customer_123456789"}
    Squeeze.MockPaymentProcessor
    |> expect(:create_customer, fn(_) -> {:ok, customer} end)

    {:ok, []}
  end

  defp mock_create_subscription(_) do
    subscription = %{
      id: "sub_123456789",
      trial_end: Timex.now() |> Timex.shift(days: 30) |> DateTime.to_unix()
    }

    Squeeze.MockPaymentProcessor
    |> expect(:create_subscription, fn(_, _, _) -> {:ok, subscription} end)

    {:ok, []}
  end
end

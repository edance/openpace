defmodule Squeeze.Setup.StripeSetupTest do
  use Squeeze.DataCase

  import Mox

  alias Squeeze.Setup.StripeSetup

  describe "#setup" do
    setup [:setup_mocks]

    test "calls create_product and create_plan" do
      assert {:ok, _} = StripeSetup.setup()
    end

    test "creates a billing plan" do
    end
  end

  defp setup_mocks(_) do
    cost_in_dollars = 10

    product = %{
      id: "product_123456789",
      name: "Monthly membership base fee",
      type: "service"
    }

    plan = %{
      id: "plan_123456789",
      currency: "usd",
      interval: "month",
      product_id: "product_123456789",
      amount: cost_in_dollars * 100
    }

    Squeeze.MockPaymentProcessor
    |> expect(:create_product, fn _ -> {:ok, product} end)

    Squeeze.MockPaymentProcessor
    |> expect(:create_plan, fn _ -> {:ok, plan} end)

    {:ok, []}
  end
end

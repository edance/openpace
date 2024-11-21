defmodule Squeeze.Setup.StripeSetup do
  @moduledoc """
  Creates the required stripe billing setup.
  """

  alias Squeeze.Billing

  def setup do
    product = create_product()
    plan = create_plan(product)

    attrs = %{
      name: product.name,
      amount: plan.amount,
      provider_id: plan.id,
      interval: plan.interval,
      default: true
    }

    Billing.create_plan(attrs)
  end

  defp create_product do
    attrs = %{
      name: "Membership",
      type: "service"
    }

    {:ok, product} = payment_module().create_product(attrs)
    product
  end

  defp create_plan(%{id: product_id}) do
    cost_in_cents = 595

    attrs = %{
      currency: "usd",
      interval: "month",
      product: product_id,
      amount: cost_in_cents
    }

    {:ok, plan} = payment_module().create_plan(attrs)
    plan
  end

  defp payment_module do
    Application.get_env(:squeeze, :payment_processor, Squeeze.StripePaymentProcessor)
  end
end

defmodule Squeeze.Setup.StripeSetup do
  @moduledoc """
  Creates the required stripe billing setup.
  """

  @payment_processor Application.get_env(:squeeze, :payment_processor)

  def setup do
    product = create_product()
    plan = create_plan(product)
    {:ok, %{product: product, plan: plan}}
  end

  defp create_product do
    attrs = %{
      name: "Monthly membership base fee",
      type: "service"
    }
    {:ok, product} = @payment_processor.create_product(attrs)
    product
  end

  defp create_plan(%{id: product_id}) do
    cost_in_dollars = 10
    attrs = %{
      currency: "usd",
      interval: "month",
      product: product_id,
      amount: cost_in_dollars * 100
    }
    {:ok, plan} = @payment_processor.create_plan(attrs)
    plan
  end
end

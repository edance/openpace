defmodule Mix.Tasks.Setup.Stripe do
  use Mix.Task

  @moduledoc """
  Creates the required stripe billing setup. This task must be run for both
  test and live stripe environment keys.

  * Creates a product
  * Creates a plan for $10.00 a month

  ## Examples

    cmd> mix setup.stripe
    Created stripe product prod_EOFa0u5fMBxRqd
    Created stripe plan plan_EOxadIoraD2MOx
  """

  alias Stripe.{Plan, Product}

  @doc false
  def run(_) do
    Mix.Task.run("app.start")
    product = create_product()
    Mix.shell.info("Created stripe product #{product.id}")
    plan = create_plan(product)
    Mix.shell.info("Created stripe plan #{plan.id}")
  end

  defp create_product do
    attrs = %{
      name: "Monthly membership base fee",
      type: "service"
    }
    {:ok, product} = Product.create(attrs)
    product
  end

  defp create_plan(%Product{id: product_id}) do
    cost_in_dollars = 10
    attrs = %{
      currency: "usd",
      interval: "month",
      product: product_id,
      amount: cost_in_dollars * 100
    }
    {:ok, plan} = Plan.create(attrs)
    plan
  end
end

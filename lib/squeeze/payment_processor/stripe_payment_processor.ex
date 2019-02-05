defmodule Squeeze.StripePaymentProcessor do
  @behaviour Squeeze.PaymentProcessor

  @moduledoc """
  Small wrapper around Stripe
  """

  alias Stripe.{Card, Plan, Product}

  def create_card(params), do: Card.create(params)
  def create_plan(params), do: Plan.create(params)
  def create_product(params), do: Product.create(params)
end

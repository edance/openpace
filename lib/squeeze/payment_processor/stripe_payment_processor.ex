defmodule Squeeze.StripePaymentProcessor do
  @behaviour Squeeze.PaymentProcessor

  @moduledoc """
  Small wrapper around Stripe
  """

  alias Stripe.{Card, Customer, Plan, Product, Subscription}

  def create_card(params), do: Card.create(params)
  def create_plan(params), do: Plan.create(params)
  def create_product(params), do: Product.create(params)

  def create_customer(params) do
    attrs = %{
      email: params[:email],
      metadata: %{
        name: "#{params[:first_name]} #{params[:last_name]}",
        id: params[:id]
      }
    }
    Customer.create(attrs)
  end

  def create_subscription(customer_id, plan_id, trial_period_days) do
    params = %{
      customer: customer_id,
      items: [%{plan: plan_id}],
      trial_period_days: trial_period_days
    }
    Subscription.create(params)
  end

  def cancel_subscription(subscription_id) do
    Subscription.delete(subscription_id)
  end
end

defmodule Squeeze.StripePaymentProcessor do
  @behaviour Squeeze.PaymentProcessor

  @moduledoc """
  Small wrapper around Stripe
  """

  alias Stripe.Card

  def create_card(params), do: Card.create(params)
end

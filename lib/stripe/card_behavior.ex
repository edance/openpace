defmodule Stripe.CardBehavior do
  @moduledoc """
  Behavior to allow us to use mocks for Stripe.Card
  """

  @callback create(map()) ::
  {:ok, Stripe.Card.t()} | {:error, Stripe.Error.t()}
end

defmodule Squeeze.PaymentProcessor do
  @moduledoc """
  Wrapper around our payment processor
  """

  @callback create_card(map()) :: {:ok, struct()} | {:error, struct()}
  @callback create_customer(map()) :: {:ok, struct()} | {:error, struct()}
  @callback create_plan(map()) :: {:ok, struct()} | {:error, struct()}
  @callback create_product(map()) :: {:ok, struct()} | {:error, struct()}
  @callback create_subscription(String.t, String.t, integer) ::
  {:ok, struct()} | {:error, struct()}
  @callback cancel_subscription(String.t) :: {:ok, struct()} | {:error, struct()}
end

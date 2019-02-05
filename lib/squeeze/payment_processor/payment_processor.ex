defmodule Squeeze.PaymentProcessor do
  @moduledoc """
  Wrapper around our payment processor
  """

  @callback create_card(map()) :: {:ok, struct()} | {:error, struct()}

  @callback create_product(map()) :: {:ok, struct()} | {:error, struct()}
  @callback create_plan(map()) :: {:ok, struct()} | {:error, struct()}
end

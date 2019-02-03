defmodule Squeeze.PaymentProcessor do
  @moduledoc """
  Wrapper around our payment processor
  """

  @callback create_card(map()) :: {:ok, struct()} | {:error, struct()}
end

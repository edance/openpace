defmodule Mix.Tasks.Setup.Stripe do
  use Mix.Task

  @moduledoc """
  Creates the required stripe billing setup. This task must be run for both
  test and live stripe environment keys.

  * Creates a product
  * Creates a plan for $5.95 a month

  ## Examples

    cmd> mix setup.stripe
    Created stripe product prod_EOFa0u5fMBxRqd
    Created stripe plan plan_EOxadIoraD2MOx
  """

  alias Squeeze.Setup.StripeSetup

  @doc false
  def run(_) do
    Mix.Task.run("app.start")
    StripeSetup.setup()
  end
end

defmodule Squeeze.BillingPlanFactory do
  @moduledoc false

  alias Faker.Lorem
  alias Squeeze.Billing.Plan

  defmacro __using__(_opts) do
    quote do
      def billing_plan_factory do
        %Plan{
          name: "Base Monthly Fee",
          amount: 1_000,
          provider_id: "plan_#{Lorem.characters(15)}",
          interval: "month"
        }
      end
    end
  end
end

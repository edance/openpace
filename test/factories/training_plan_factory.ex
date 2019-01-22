defmodule Squeeze.TrainingPlanFactory do
  @moduledoc false

  alias Squeeze.TrainingPlans.Plan

  defmacro __using__(_opts) do
    quote do
      def training_plan_factory do
        miles = Enum.random(2..16)

        %Plan{
          name: "#{miles} mi run",
          week_count: 18,
          user: build(:user)
        }
      end
    end
  end
end

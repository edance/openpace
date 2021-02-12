defmodule Squeeze.ActivityFactory do
  @moduledoc false

  alias Faker.{Date}
  alias Squeeze.Dashboard.Activity

  defmacro __using__(_opts) do
    quote do
      def activity_factory do
        miles = Enum.random(2..16) # 2-16 miles
        pace = Enum.random(5..8) # 5-9 min/miles
        %Activity{
          distance: miles * 1609.0,
          duration: pace * miles * 60,
          name: Enum.random(["Morning Run", "Afternoon Run", "Evening Run"]),
          type: "Run",
          activity_type: :run,
          start_at: DateTime.utc_now,
          external_id: sequence(:external_id, &("#{&1}")),
          polyline: "abc",
          user: build(:user)
        }
      end

      def planned_activity_factory do
        miles = Enum.random(2..16) # 2-16 miles
        pace = Enum.random(5..8) # 5-9 min/miles
        %Activity{
          planned_date: Date.forward(100),
          planned_distance: miles * 1609.0,
          planned_duration: pace * miles * 60,
          status: :pending,
          name: "#{miles} mi",
          type: "Run",
          activity_type: :run,
          user: build(:user)
        }
      end
    end
  end
end

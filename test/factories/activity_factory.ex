defmodule Squeeze.ActivityFactory do
  @moduledoc false

  alias Faker.{Date}
  alias Squeeze.Dashboard.Activity
  import Squeeze.Utils, only: [random_float: 2]

  defmacro __using__(_opts) do
    quote do
      def activity_factory(attrs) do
        miles = random_float(2, 16) # 2-16 miles
        pace = random_float(5, 9) # 5-9 min/miles
        elevation_gain = Float.round(Enum.random(600..2000) / 3.28, 2)
        timezone = "America/Los_Angeles"
        start_at = Map.get(attrs, :start_at, Timex.now())

        %Activity{
          distance: miles * 1609.0,
          duration: round(pace * miles * 60),
          name: Enum.random(["Morning Run", "Afternoon Run", "Evening Run"]),
          type: "Run",
          activity_type: :run,
          start_at: start_at,
          start_at_local: Timex.to_datetime(start_at, timezone),
          planned_date: Timex.to_datetime(start_at, timezone) |> Timex.to_date(),
          status: :complete,
          external_id: sequence(:external_id, &("#{&1}")),
          polyline: nil,
          elevation_gain: elevation_gain,
          workout_type: nil,
          user: build(:user),
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end

      def planned_activity_factory do
        miles = Enum.random(2..16) # 2-16 miles
        pace = Enum.random(5..8) # 5-9 min/miles
        %Activity{
          planned_date: Date.forward(100),
          planned_distance: miles * 1609.0,
          planned_duration: round(pace * miles * 60),
          status: :pending,
          name: "#{miles} mi",
          type: "Run",
          activity_type: :run,
          user: build(:user)
        }
      end

      def at_datetime(%Activity{} = activity, datetime, timezone \\ "America/Los_Angeles") do
        %{activity |
          start_at: Timex.to_datetime(datetime),
          start_at_local: Timex.to_datetime(datetime, timezone),
          planned_date: Timex.to_datetime(datetime, timezone) |> Timex.to_date(),
        }
      end
    end
  end
end

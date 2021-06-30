defmodule Squeeze.DetailedActivityFactory do
  @moduledoc false

  alias Strava.DetailedActivity

  defmacro __using__(_opts) do
    quote do
      def detailed_activity_factory do
        timezone = "America/New_York"

        %DetailedActivity{
          id: sequence(:external_id, &(&1)),
          name: Enum.random(["Morning Run", "Afternoon Run", "Evening Run"]),
          distance: 5000.0,
          moving_time: 1_200, # 20 minutes
          start_date: Timex.now(),
          start_date_local: Timex.to_datetime(Timex.now(), timezone),
          map: %{summary_polyline: "ABCDEF"},
          type: "Run"
        }
      end
    end
  end
end

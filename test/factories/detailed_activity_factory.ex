defmodule Squeeze.DetailedActivityFactory do
  @moduledoc false

  alias Strava.DetailedActivity

  defmacro __using__(_opts) do
    quote do
      def detailed_activity_factory do
        timezone = "America/New_York"
        now = Timex.now()

        # Strava sends a datetime without a timezone for the start_date_local
        local =
          now
          |> Timex.to_datetime(timezone)
          |> Timex.format!("%FT%TZ", :strftime)
          |> Timex.parse!("{ISO:Extended:Z}")

        %DetailedActivity{
          id: sequence(:external_id, & &1),
          name: Enum.random(["Morning Run", "Afternoon Run", "Evening Run"]),
          distance: 5000.0,
          moving_time: 1_200,
          start_date: now,
          start_date_local: local,
          map: %{summary_polyline: "ABCDEF"},
          type: "Run"
        }
      end
    end
  end
end

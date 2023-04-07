defmodule Squeeze.LapFactory do
  @moduledoc false

  alias Squeeze.Activities.{Lap}
  import Squeeze.Utils, only: [random_float: 2, random_int: 2]

  defmacro __using__(_opts) do
    quote do
      def lap_factory(attrs) do
        # random pace between 5-9 min/miles
        pace = random_float(5, 9)

        # between 1 km and 1 mile
        distance = random_float(1000, 1609)
        moving_time = round(distance / 1609 * pace * 60)

        # random amount of additional time
        additional_time = random_int(0, 60)

        activity = Map.get(attrs, :activity, build(:activity))

        %Lap{
          average_cadence: random_float(150, 170) / 2,
          average_speed: "",
          distance: distance,
          elapsed_time: moving_time + additional_time,
          lap_index: 0,
          max_speed: "",
          moving_time: moving_time,
          name: "Lap",
          split: 0,
          start_date: activity.start_at,
          start_date_local: activity.start_at_local,
          total_elevation_gain: random_float(-100, 100),
          start_index: 0,
          end_index: 0,
          activity: activity
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end

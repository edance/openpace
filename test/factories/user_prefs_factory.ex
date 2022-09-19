defmodule Squeeze.UserPrefsFactory do
  @moduledoc false

  alias Squeeze.Accounts.UserPrefs
  alias Squeeze.Distances
  import Squeeze.Utils, only: [random_float: 2]

  defmacro __using__(_opts) do
    quote do
      def user_prefs_factory do
        marathon_pace = random_float(5, 9) # 5-9 min/miles
        half_pace = marathon_pace * 0.95 # 5% faster than MP

        marathon_duration = round(Distances.marathon_in_meters() / 1609 * marathon_pace * 60)
        half_duration = round(Distances.half_marathon_in_meters() / 1609 * half_pace * 60)

        %UserPrefs{
          timezone: "America/Los_Angeles",
          imperial: true,
          personal_records: [
            %{
              distance: Distances.half_marathon_in_meters(),
              duration: half_duration
            },
            %{
              distance: Distances.marathon_in_meters(),
              duration: marathon_duration
            }
          ]
        }
      end
    end
  end
end

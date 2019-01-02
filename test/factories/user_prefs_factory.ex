defmodule Squeeze.UserPrefsFactory do
  @moduledoc false

  alias Squeeze.Accounts.UserPrefs

  alias Faker.{Date}

  defmacro __using__(_opts) do
    quote do
      def user_prefs_factory do
        %UserPrefs{
          distance: 42_195, # Marathon in meters
          duration: 3 * 60 * 60, # 3 hours in seconds
          personal_record: 3 * 60 * 60, # 3 hours in seconds
          race_date: Date.forward(100),
          timezone: "America/New_York"
        }
      end
    end
  end
end

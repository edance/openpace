defmodule Squeeze.UserPrefsFactory do
  @moduledoc false

  alias Squeeze.Accounts.UserPrefs

  alias Faker.{Date}

  defmacro __using__(_opts) do
    quote do
      def user_prefs_factory do
        %UserPrefs{
          timezone: "America/New_York",
          imperial: true
        }
      end
    end
  end
end

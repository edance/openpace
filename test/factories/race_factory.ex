defmodule Squeeze.RaceFactory do
  @moduledoc false

  alias Faker.{Address}
  alias Squeeze.Races.Race

  defmacro __using__(_opts) do
    quote do
      def race_factory do
        city = Address.city()
        race = Enum.random(["Marathon", "Half Marathon", "Ultramarathon"])
        name = "#{city} #{race}"
        %Race{
          name: name,
          slug: name |> String.downcase() |> String.split() |> Enum.join("-"),
          city: city,
          state: Address.state_abbr()
        }
      end
    end
  end
end

defmodule Squeeze.RaceFactory do
  @moduledoc false

  alias Faker.{Address, Lorem, NaiveDateTime}
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
          timezone: "America/New_York",
          overview: Lorem.paragraph(),
          description: Lorem.paragraph(3),
          distance: 42_195.0,
          distance_type: race |> String.downcase() |> String.split(" ") |> Enum.join("_"),
          start_at: NaiveDateTime.forward(100),
          state: Address.state_abbr()
        }
      end
    end
  end
end

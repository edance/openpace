defmodule Squeeze.RaceFactory do
  @moduledoc false

  alias Faker.{Address, Lorem}
  alias Squeeze.Distances
  alias Squeeze.Races.Race

  defmacro __using__(_opts) do
    quote do
      def race_factory do
        city = Address.city()
        state = Address.state_abbr()
        race = Enum.random(Distances.distances)
        name = "#{city} #{race.name}"
        slug = "/races/#{state}/#{city}/#{name}"
        |> String.downcase()
        |> String.split()
        |> Enum.join("-")

        %Race{
          name: name,
          slug: slug,
          city: city,
          timezone: "America/New_York",
          content: Lorem.paragraph(6),
          state: state,
          external_id: sequence(:external_id, &"#{&1}")
        }
      end

      def with_events(%Race{} = race) do
        events = build_pair(:race_event, race: race)
        %{race | events: events}
      end
    end
  end
end

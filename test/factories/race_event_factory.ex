defmodule Squeeze.RaceEventFactory do
  @moduledoc false

  alias Faker.{Lorem, NaiveDateTime}
  alias Squeeze.Distances
  alias Squeeze.Races.Event

  defmacro __using__(_opts) do
    quote do
      def race_event_factory do
        race = Enum.random(Distances.distances())

        %Event{
          name: race.name,
          details: Lorem.paragraph(1),
          start_at: NaiveDateTime.forward(100),
          distance: race.distance,
          distance_name: race.name,
          race: build(:race)
        }
      end
    end
  end
end

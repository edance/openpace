defmodule Squeeze.DetailedAthleteFactory do
  @moduledoc false

  alias Faker.Person
  alias Strava.DetailedAthlete

  defmacro __using__(_opts) do
    quote do
      def detailed_athlete_factory do
        %DetailedAthlete{
          id: sequence(:external_id, & &1),
          firstname: Person.first_name(),
          lastname: Person.last_name(),
          profile: ""
        }
      end
    end
  end
end

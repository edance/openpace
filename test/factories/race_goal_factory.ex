defmodule Squeeze.RaceGoalFactory do
  @moduledoc false

  alias Faker.{Address, Date}
  alias Squeeze.Distances
  alias Squeeze.Races.{TrainingPace, RaceGoal}
  import Squeeze.Utils, only: [random_float: 2]

  defmacro __using__(_opts) do
    quote do
      def race_goal_factory do
        %{distance: distance, name: distance_name} = race_distance()
        # random pace between 5-9 min/miles
        pace = random_float(5, 9)
        duration = round(distance / 1609 * pace * 60)

        %RaceGoal{
          race_name: "#{Address.city()} #{distance_name}",
          slug: sequence(:slug, &"#{&1}"),
          distance: distance,
          duration: duration,
          just_finish: false,
          # Up to 18 weeks away
          race_date: Date.forward(18 * 7),
          training_paces: TrainingPace.default_paces(distance, duration),
          user: build(:user)
        }
      end

      def just_finish_goal(%RaceGoal{} = race_goal) do
        %{race_goal | just_finish: true, duration: nil, training_paces: []}
      end

      defp race_distance do
        Distances.distances()
        # Half or greater
        |> Enum.filter(&(&1.distance >= 21_097))
        |> Enum.random()
      end
    end
  end
end

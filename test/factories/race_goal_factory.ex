defmodule Squeeze.RaceGoalFactory do
  @moduledoc false

  alias Squeeze.Distances
  alias Squeeze.Races.{TrainingPace, RaceGoal}

  defmacro __using__(_opts) do
    quote do
      def race_goal_factory do
        distance = race_distance()
        pace = Enum.random(5..9) # 5-9 min/miles
        duration = round(distance / 1609 * pace * 60)

        %RaceGoal{
          slug: sequence(:slug, &("#{&1}")),
          distance: distance,
          duration: duration,
          just_finish: false,
          training_paces: TrainingPace.default_paces(distance, duration),
          user: build(:user),
          race: build(:race)
        }
      end

      def just_finish_goal(%RaceGoal{} = race_goal) do
        %{race_goal | just_finish: true, duration: nil, training_paces: []}
      end

      defp race_distance do
        Distances.distances()
        |> Enum.filter(&(&1.distance >= 21_097)) # Half or greater
        |> Enum.random()
        |> Map.get(:distance)
      end
    end
  end
end

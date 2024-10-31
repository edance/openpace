defmodule Squeeze.RaceGoalFactory do
  @moduledoc false

  alias Faker.{Address, Date}
  alias Squeeze.Distances
  alias Squeeze.Races.{RaceGoal, TrainingPace}
  import Squeeze.Utils, only: [random_float: 2]

  defmacro __using__(_opts) do
    quote do
      def race_goal_factory(attrs) do
        %{distance: distance, name: distance_name} = race_distance()
        # random pace between 5-9 min/miles
        pace = random_float(5, 9)
        duration = Map.get(attrs, :duration, round(distance / 1609 * pace * 60))
        paces = TrainingPace.default_paces(%{distance: distance, duration: duration})

        %RaceGoal{
          race_name: "#{Address.city()} #{distance_name}",
          slug: sequence(:slug, &"#{Squeeze.SlugGenerator.gen_slug()}#{&1}"),
          distance: distance,
          duration: duration,
          just_finish: false,
          # Up to 18 weeks away
          race_date: Date.forward(18 * 7),
          training_paces: paces,
          user: build(:user)
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end

      def with_activity(%RaceGoal{} = race_goal) do
        %{distance: distance, duration: duration} = race_goal

        attrs = %{
          distance: distance,
          duration: duration,
          name: race_goal.race_name
        }

        activity = insert(:activity, attrs)
        paces = TrainingPace.default_paces(%{distance: distance, duration: duration})
        race_date = Timex.to_date(activity.start_at_local)

        %{
          race_goal
          | activity: activity,
            activity_id: activity.id,
            race_date: race_date,
            training_paces: paces
        }
      end

      defp race_distance do
        Distances.distances() |> Enum.filter(&(&1.distance >= 21_097)) |> Enum.random()
      end
    end
  end
end

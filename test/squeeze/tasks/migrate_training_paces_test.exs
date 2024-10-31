defmodule Squeeze.Tasks.MigrateTrainingPacesTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Squeeze.Races.TrainingPace
  alias Squeeze.Repo
  alias Squeeze.Tasks.MigrateTrainingPaces

  describe "#run" do
    test "creates default training paces for race_goals" do
      goal_1 = insert(:race_goal)
      goal_2 = insert(:race_goal, just_finish: true, duration: nil)

      MigrateTrainingPaces.run()

      paces = Repo.all(TrainingPace)

      assert Enum.filter(paces, &(&1.race_goal_id == goal_1.id)) != []
      assert Enum.filter(paces, &(&1.race_goal_id == goal_2.id)) == []
    end
  end
end

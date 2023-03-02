defmodule Squeeze.RacesTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Squeeze.Races

  describe "races" do
    test "get_race!/1 returns the race with given slug" do
      race = insert(:race)
      slug = race.slug
      assert Races.get_race!(slug).slug == slug
    end
  end

  describe "race_goals" do
    test "get_race_goal!/1 returns the race with given slug" do
      race_goal = insert(:race_goal)
      slug = race_goal.slug
      assert Races.get_race_goal!(slug).slug == slug
    end

    test "create_race_goal/2 with valid attrs" do
      user = insert(:user)
      attrs = params_for(:race_goal)

      {:ok, race_goal} = Races.create_race_goal(user, attrs)
      assert race_goal.slug
    end

    test "create_race_goal/2 with invalid attrs" do
      user = insert(:user)
      attrs = params_for(:race_goal)
      attrs = Map.merge(attrs, %{distance: nil})

      assert {:error, _} = Races.create_race_goal(user, attrs)
    end
  end
end

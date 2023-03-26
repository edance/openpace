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

  describe "find_or_create_race_goal_from_activity/1" do
    test "returns the existing race_goal if matches date and user" do
      activity = insert(:activity)
      {:ok, goal} = Races.create_race_goal_from_activity(activity)

      res = Races.find_or_create_race_goal_from_activity(activity)
      assert {:ok, %{id: id}} = res
      assert id == goal.id
    end

    test "creates a race_goal if does not match user" do
      activity = insert(:activity)
      goal = insert(:race_goal, race_date: Timex.to_date(activity.start_at_local))

      res = Races.find_or_create_race_goal_from_activity(activity)
      assert {:ok, %{id: id}} = res
      refute id == goal.id
    end

    test "creates a race_goal if does not match date" do
      activity = insert(:activity)
      goal = insert(:race_goal, user: activity.user)

      res = Races.find_or_create_race_goal_from_activity(activity)
      assert {:ok, %{id: id}} = res
      refute id == goal.id
    end
  end

  describe "create_race_goal_from_activity/1" do
    test "creates a race_goal" do
      activity = insert(:activity)
      {:ok, goal} = Races.create_race_goal_from_activity(activity)

      assert goal.race_name == activity.name
      assert goal.duration == activity.duration
      assert goal.distance == activity.distance
      assert goal.race_date == Timex.to_date(activity.start_at_local)
    end

    test "does not allow two race goals with the same activity" do
      activity = insert(:activity)
      Races.create_race_goal_from_activity(activity)

      assert {:error, _} = Races.create_race_goal_from_activity(activity)
    end
  end
end

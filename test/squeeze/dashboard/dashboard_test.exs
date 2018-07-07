defmodule Squeeze.DashboardTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard

  import Squeeze.Factory

  describe "goals" do
    alias Squeeze.Dashboard.Goal

    @valid_attrs params_for(:goal)
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{distance: nil, duration: nil}

    test "list_goals/1 returns all users goals" do
      goal = insert(:goal)
      assert Dashboard.list_goals(goal.user) == [goal]
    end

    test "get_goal!/1 returns the goal with given id" do
      goal = insert(:goal)
      assert Dashboard.get_goal!(goal.id) == goal
    end

    test "create_goal/2 with valid data creates a goal" do
      user = insert(:user)
      assert {:ok, %Goal{} = goal} = Dashboard.create_goal(user, @valid_attrs)
      assert goal.name == @valid_attrs.name
    end

    test "create_goal/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_goal(@invalid_attrs)
    end

    test "update_goal/2 with valid data updates the goal" do
      goal = insert(:goal)
      assert {:ok, goal} = Dashboard.update_goal(goal, @update_attrs)
      assert %Goal{} = goal
      assert goal.name == "some updated name"
    end

    test "update_goal/2 with invalid data returns error changeset" do
      goal = insert(:goal)
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_goal(goal, @invalid_attrs)
      assert goal == Dashboard.get_goal!(goal.id)
    end

    test "delete_goal/1 deletes the goal" do
      goal = insert(:goal)
      assert {:ok, %Goal{}} = Dashboard.delete_goal(goal)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_goal!(goal.id) end
    end

    test "change_goal/1 returns a goal changeset" do
      goal = insert(:goal)
      assert %Ecto.Changeset{} = Dashboard.change_goal(goal)
    end
  end

  describe "paces" do
    alias Squeeze.Dashboard.Pace

    @valid_attrs params_for(:pace)
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil, offset: nil}

    test "list_paces/1 returns all users paces" do
      pace = insert(:pace)
      assert Dashboard.list_paces(pace.user) == [pace]
    end

    test "get_pace!/1 returns the pace with given id" do
      pace = insert(:pace)
      assert Dashboard.get_pace!(pace.id) == pace
    end

    test "create_pace/2 with valid data creates a pace" do
      user = insert(:user)
      assert {:ok, %Pace{} = pace} = Dashboard.create_pace(user, @valid_attrs)
      assert pace.name == @valid_attrs.name
      assert pace.offset == @valid_attrs.offset
    end

    test "create_pace/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_pace(user, @invalid_attrs)
    end

    test "update_pace/2 with valid data updates the pace" do
      pace = insert(:pace)
      assert {:ok, pace} = Dashboard.update_pace(pace, @update_attrs)
      assert %Pace{} = pace
      assert pace.name == "some updated name"
    end

    test "update_pace/2 with invalid data returns error changeset" do
      pace = insert(:pace)
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_pace(pace, @invalid_attrs)
      assert pace == Dashboard.get_pace!(pace.id)
    end

    test "delete_pace/1 deletes the pace" do
      pace = insert(:pace)
      assert {:ok, %Pace{}} = Dashboard.delete_pace(pace)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_pace!(pace.id) end
    end

    test "change_pace/1 returns a pace changeset" do
      pace = insert(:pace)
      assert %Ecto.Changeset{} = Dashboard.change_pace(pace)
    end
  end

  describe "events" do
    alias Squeeze.Dashboard.Event

    @valid_attrs params_for(:event)
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{date: nil, distance: nil}

    test "list_events/1 returns all events" do
      event = insert(:event)
      assert Dashboard.list_events(event.user) == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = insert(:event)
      assert Dashboard.get_event!(event.id) == event
    end

    test "create_event/2 with valid data creates a event" do
      user = insert(:user)
      assert {:ok, %Event{} = event} = Dashboard.create_event(user, @valid_attrs)
      assert event.name == @valid_attrs.name
    end

    test "create_event/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_event(user, @invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = insert(:event)
      assert {:ok, event} = Dashboard.update_event(event, @update_attrs)
      assert %Event{} = event
      assert event.name == "some updated name"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = insert(:event)
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_event(event, @invalid_attrs)
      assert event == Dashboard.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = insert(:event)
      assert {:ok, %Event{}} = Dashboard.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = insert(:event)
      assert %Ecto.Changeset{} = Dashboard.change_event(event)
    end
  end

  describe "activities" do
    alias Squeeze.Dashboard.Activity

    @valid_attrs params_for(:activity)
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{distance: nil, duration: nil, name: nil, start_at: nil}

    test "list_activities/1 returns all activities" do
      activity = insert(:activity)
      assert Dashboard.list_activities(activity.user) == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = insert(:activity)
      assert Dashboard.get_activity!(activity.id) == activity
    end

    test "create_activity/2 with valid data creates a activity" do
      user = insert(:user)
      assert {:ok, %Activity{} = activity} = Dashboard.create_activity(user, @valid_attrs)
      assert activity.name == @valid_attrs.name
    end

    test "create_activity/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_activity(user, @invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = insert(:activity)
      assert {:ok, activity} = Dashboard.update_activity(activity, @update_attrs)
      assert %Activity{} = activity
      assert activity.name == "some updated name"
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = insert(:activity)
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_activity(activity, @invalid_attrs)
      assert activity == Dashboard.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = insert(:activity)
      assert {:ok, %Activity{}} = Dashboard.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = insert(:activity)
      assert %Ecto.Changeset{} = Dashboard.change_activity(activity)
    end
  end
end

defmodule Squeeze.DashboardTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard

  describe "activities" do
    alias Squeeze.Dashboard.Activity

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def activity_fixture(attrs \\ %{}) do
      {:ok, activity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboard.create_activity()

      activity
    end

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Dashboard.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Dashboard.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      assert {:ok, %Activity{} = activity} = Dashboard.create_activity(@valid_attrs)
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      assert {:ok, activity} = Dashboard.update_activity(activity, @update_attrs)
      assert %Activity{} = activity
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_activity(activity, @invalid_attrs)
      assert activity == Dashboard.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Dashboard.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_activity(activity)
    end
  end

  describe "goals" do
    alias Squeeze.Dashboard.Goal

    @valid_attrs %{current: true, date: ~D[2010-04-17], distance: 120.5, duration: 42, name: "some name"}
    @update_attrs %{current: false, date: ~D[2011-05-18], distance: 456.7, duration: 43, name: "some updated name"}
    @invalid_attrs %{current: nil, date: nil, distance: nil, duration: nil, name: nil}

    def goal_fixture(attrs \\ %{}) do
      {:ok, goal} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboard.create_goal()

      goal
    end

    test "list_goals/0 returns all goals" do
      goal = goal_fixture()
      assert Dashboard.list_goals() == [goal]
    end

    test "get_goal!/1 returns the goal with given id" do
      goal = goal_fixture()
      assert Dashboard.get_goal!(goal.id) == goal
    end

    test "create_goal/1 with valid data creates a goal" do
      assert {:ok, %Goal{} = goal} = Dashboard.create_goal(@valid_attrs)
      assert goal.current == true
      assert goal.date == ~D[2010-04-17]
      assert goal.distance == 120.5
      assert goal.duration == 42
      assert goal.name == "some name"
    end

    test "create_goal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_goal(@invalid_attrs)
    end

    test "update_goal/2 with valid data updates the goal" do
      goal = goal_fixture()
      assert {:ok, goal} = Dashboard.update_goal(goal, @update_attrs)
      assert %Goal{} = goal
      assert goal.current == false
      assert goal.date == ~D[2011-05-18]
      assert goal.distance == 456.7
      assert goal.duration == 43
      assert goal.name == "some updated name"
    end

    test "update_goal/2 with invalid data returns error changeset" do
      goal = goal_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_goal(goal, @invalid_attrs)
      assert goal == Dashboard.get_goal!(goal.id)
    end

    test "delete_goal/1 deletes the goal" do
      goal = goal_fixture()
      assert {:ok, %Goal{}} = Dashboard.delete_goal(goal)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_goal!(goal.id) end
    end

    test "change_goal/1 returns a goal changeset" do
      goal = goal_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_goal(goal)
    end
  end

  describe "paces" do
    alias Squeeze.Dashboard.Pace

    @valid_attrs %{name: "some name", offset: 42}
    @update_attrs %{name: "some updated name", offset: 43}
    @invalid_attrs %{name: nil, offset: nil}

    def pace_fixture(attrs \\ %{}) do
      {:ok, pace} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboard.create_pace()

      pace
    end

    test "list_paces/0 returns all paces" do
      pace = pace_fixture()
      assert Dashboard.list_paces() == [pace]
    end

    test "get_pace!/1 returns the pace with given id" do
      pace = pace_fixture()
      assert Dashboard.get_pace!(pace.id) == pace
    end

    test "create_pace/1 with valid data creates a pace" do
      assert {:ok, %Pace{} = pace} = Dashboard.create_pace(@valid_attrs)
      assert pace.name == "some name"
      assert pace.offset == 42
    end

    test "create_pace/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_pace(@invalid_attrs)
    end

    test "update_pace/2 with valid data updates the pace" do
      pace = pace_fixture()
      assert {:ok, pace} = Dashboard.update_pace(pace, @update_attrs)
      assert %Pace{} = pace
      assert pace.name == "some updated name"
      assert pace.offset == 43
    end

    test "update_pace/2 with invalid data returns error changeset" do
      pace = pace_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_pace(pace, @invalid_attrs)
      assert pace == Dashboard.get_pace!(pace.id)
    end

    test "delete_pace/1 deletes the pace" do
      pace = pace_fixture()
      assert {:ok, %Pace{}} = Dashboard.delete_pace(pace)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_pace!(pace.id) end
    end

    test "change_pace/1 returns a pace changeset" do
      pace = pace_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_pace(pace)
    end
  end

  describe "events" do
    alias Squeeze.Dashboard.Event

    @valid_attrs %{cooldown: true, date: ~D[2010-04-17], distance: 120.5, name: "some name", warmup: true}
    @update_attrs %{cooldown: false, date: ~D[2011-05-18], distance: 456.7, name: "some updated name", warmup: false}
    @invalid_attrs %{cooldown: nil, date: nil, distance: nil, name: nil, warmup: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboard.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Dashboard.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Dashboard.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Dashboard.create_event(@valid_attrs)
      assert event.cooldown == true
      assert event.date == ~D[2010-04-17]
      assert event.distance == 120.5
      assert event.name == "some name"
      assert event.warmup == true
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, event} = Dashboard.update_event(event, @update_attrs)
      assert %Event{} = event
      assert event.cooldown == false
      assert event.date == ~D[2011-05-18]
      assert event.distance == 456.7
      assert event.name == "some updated name"
      assert event.warmup == false
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_event(event, @invalid_attrs)
      assert event == Dashboard.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Dashboard.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_event(event)
    end
  end

  describe "activities" do
    alias Squeeze.Dashboard.Activity

    @valid_attrs %{distance: 120.5, duration: 42, name: "some name", start_at: ~N[2010-04-17 14:00:00.000000]}
    @update_attrs %{distance: 456.7, duration: 43, name: "some updated name", start_at: ~N[2011-05-18 15:01:01.000000]}
    @invalid_attrs %{distance: nil, duration: nil, name: nil, start_at: nil}

    def activity_fixture(attrs \\ %{}) do
      {:ok, activity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboard.create_activity()

      activity
    end

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Dashboard.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Dashboard.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      assert {:ok, %Activity{} = activity} = Dashboard.create_activity(@valid_attrs)
      assert activity.distance == 120.5
      assert activity.duration == 42
      assert activity.name == "some name"
      assert activity.start_at == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      assert {:ok, activity} = Dashboard.update_activity(activity, @update_attrs)
      assert %Activity{} = activity
      assert activity.distance == 456.7
      assert activity.duration == 43
      assert activity.name == "some updated name"
      assert activity.start_at == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_activity(activity, @invalid_attrs)
      assert activity == Dashboard.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Dashboard.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_activity(activity)
    end
  end
end

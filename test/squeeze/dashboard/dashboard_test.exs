defmodule Squeeze.DashboardTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard
  alias Squeeze.TimeHelper

  import Squeeze.Factory

  describe "#list_activities/2" do
    test "includes only the users activities" do
      now = Timex.now
      [activity, _] = insert_pair(:activity, start_at: now)
      user = activity.user
      today = TimeHelper.to_date(user, now)
      insert_pair(:planned_activity, planned_date: today)
      range = Date.range(Timex.shift(today, days: -1), Timex.shift(today, days: 1))
      activities = Dashboard.list_activities(activity.user, range)

      assert activities |> Enum.map(&(&1.id)) |> Enum.member?(activity.id)
      assert length(activities) == 1
    end

    test "includes only activities in the date range" do
      user = insert(:user)
      today = TimeHelper.today(user)
      beginning_of_day = TimeHelper.beginning_of_day(user, today)
      end_of_day = TimeHelper.end_of_day(user, today)
      insert(:activity, user: user, start_at: beginning_of_day)
      insert(:activity, user: user, start_at: end_of_day)
      insert(:activity, user: user, start_at: Timex.shift(end_of_day, minutes: 1))
      activities = Dashboard.list_activities(user, Date.range(today, today))
      assert length(activities) == 2
    end
  end

  describe "#recent_activities/1" do
    test "includes only the users activities" do
      activity1 = insert(:activity)
      activity2 = insert(:activity, start_at: activity1.start_at)
      activities = Dashboard.recent_activities(activity1.user)
      assert activities |> Enum.map(&(&1.id)) |> Enum.member?(activity1.id)
      refute activities |> Enum.map(&(&1.id)) |> Enum.member?(activity2.id)
    end

    test "orders by most recent activities first" do
    end
  end

  describe "#todays_activities/1" do
    test "returns only activities for today" do
      user = insert(:user)
      date = TimeHelper.today(user)
      activity1 = insert(:planned_activity, %{user: user, planned_date: date})
      activity2 = insert(:planned_activity, %{user: user, planned_date: Date.add(date, 1)})
      activities = Dashboard.todays_activities(user)
      assert activities |> Enum.map(&(&1.id)) |> Enum.member?(activity1.id)
      refute activities |> Enum.map(&(&1.id)) |> Enum.member?(activity2.id)
    end
  end

  describe "#get_activity!/2" do
    test "returns the activity if found" do
      activity = insert(:activity)
      user = activity.user
      assert activity.id == Dashboard.get_activity!(user, activity.id).id
    end

    test "raises error if activity does not belong to user" do
      activity = insert(:activity)
      user = insert(:user)
      assert_raise Ecto.NoResultsError, fn ->
        Dashboard.get_activity!(user, activity.id) end
    end

    test "raises error if activity does not exist" do
      user = insert(:user)
      assert_raise Ecto.NoResultsError, fn ->
        Dashboard.get_activity!(user, "1234") end
    end
  end

  describe "create_trackpoint_set/2" do
    test "creates a trackpoint set and trackpoints" do
      activity = insert(:activity)
      trackpoints = [%{distance: 0.0, time: 0}, %{distance: 10.0, time: 4}]
      {:ok, set} = Dashboard.create_trackpoint_set(activity, trackpoints)
      assert length(set.trackpoints) == 2
      refute set.id == nil
      assert set.activity_id == activity.id
    end
  end
end

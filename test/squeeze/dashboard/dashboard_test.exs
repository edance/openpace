defmodule Squeeze.DashboardTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard
  alias Squeeze.TimeHelper

  import Squeeze.Factory

  describe "#list_activities/2" do
    test "includes only the users activities" do
      now = Timex.now
      [activity, _] = insert_pair(:activity, start_at: now)
      today = Timex.to_date(now)
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
      activity1 = insert(:activity, %{user: user, planned_date: date})
      activity2 = insert(:activity, %{user: user, planned_date: Date.add(date, 1)})
      activities = Dashboard.todays_activities(user)
      assert activities |> Enum.map(&(&1.id)) |> Enum.member?(activity1.id)
      refute activities |> Enum.map(&(&1.id)) |> Enum.member?(activity2.id)
    end
  end

  describe "#get_activity!/1" do
    test "returns the activity if found" do
      activity = insert(:activity)
      assert activity.id == Dashboard.get_activity!(activity.id).id
    end

    test "raises error if not found" do
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_activity!("1234") end
    end
  end
end

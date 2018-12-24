defmodule Squeeze.DashboardTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard

  import Squeeze.Factory

  describe "#list_activities/2" do
    test "includes only the users activities" do
      activity1 = insert(:activity)
      activity2 = insert(:activity, start_at: activity1.start_at)
      activities = Dashboard.list_activities(activity1.user, nil)
      assert activities |> Enum.map(&(&1.id)) |> Enum.member?(activity1.id)
      refute activities |> Enum.map(&(&1.id)) |> Enum.member?(activity2.id)
    end

    test "includes only activities in the date range" do
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

  describe "#get_activity!/1" do
    test "returns the activity if found" do
      activity = insert(:activity)
      assert activity.id == Dashboard.get_activity!(activity.id).id
    end

    test "raises error if not found" do
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_activity!("1234") end
    end
  end

  describe "events" do
    test "list_events/2 includes only the users events" do
      event1 = insert(:event)
      event2 = insert(:event, date: event1.date)
      range = Date.range(event1.date, Date.add(event1.date, 1))
      events = Dashboard.list_events(event1.user, range)
      assert events |> Enum.map(&(&1.id)) |> Enum.member?(event1.id)
      refute events |> Enum.map(&(&1.id)) |> Enum.member?(event2.id)
    end

    test "list_events/2 returns only the events in the range" do
      user = insert(:user)
      event1 = insert(:event, user: user)
      event2 = insert(:event, user: user, date: Date.add(event1.date, 2))
      range = Date.range(event1.date, Date.add(event1.date, 1))
      events = Dashboard.list_events(user, range)
      assert events |> Enum.map(&(&1.id)) |> Enum.member?(event1.id)
      refute events |> Enum.map(&(&1.id)) |> Enum.member?(event2.id)
    end
  end
end

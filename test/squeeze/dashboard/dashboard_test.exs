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
end

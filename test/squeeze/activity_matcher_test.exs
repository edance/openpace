defmodule Squeeze.ActivityMatcherTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory

  alias Squeeze.ActivityMatcher
  alias Squeeze.TimeHelper

  describe "get_closest_activity/2" do
    setup [:create_user, :today]

    test "with planned activity on the same day", %{user: user, today: today} do
      attrs = build(:activity, start_at: Timex.now)
      activity = insert(:planned_activity, planned_date: today, user: user, planned_distance: 1, planned_duration: 1)
      insert(:planned_activity, status: :complete, planned_date: today, user: user, planned_distance: 1, planned_duration: 1)

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with complete activity on the same day", %{user: user, today: today} do
      activity = insert(:planned_activity, status: :complete, planned_date: today, user: user)
      attrs = build(:activity, start_at: Timex.now)

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with distance match on the same day", %{user: user, today: today} do
      [activity, _] = insert_pair(:planned_activity, planned_date: today, user: user, planned_duration: 1)
      attrs = build(:activity, start_at: Timex.now, distance: activity.planned_distance, planned_duration: 1)

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with duration match on the same day", %{user: user, today: today} do
      [activity, _] = insert_pair(:planned_activity, planned_date: today, user: user, planned_distance: 1)
      attrs = build(:activity, start_at: Timex.now, duration: activity.planned_duration, planned_distance: 1)

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with an activity of a different type", %{user: user, today: today} do
      insert(:planned_activity, planned_date: today, user: user)
      attrs = build(:activity, start_at: Timex.now, type: "Yoga")

      assert ActivityMatcher.get_closest_activity(user, attrs) == nil
    end

    test "with an activity with the same external_id", %{user: user} do
      now = Timex.now
      [_, activity] = insert_pair(:activity, user: user, start_at: now)
      attrs = build(:activity, start_at: Timex.now, external_id: activity.external_id)

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end

  defp today(%{user: user}) do
    today = TimeHelper.today(user)
    {:ok, today: today}
  end
end

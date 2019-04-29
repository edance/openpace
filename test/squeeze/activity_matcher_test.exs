defmodule Squeeze.ActivityMatcherTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory

  alias Squeeze.ActivityMatcher
  alias Squeeze.Dashboard.Activity
  alias Squeeze.TimeHelper

  describe "get_closest_activity/2" do
    test "with planned activity on the same day" do
      user = insert(:user)
      today = TimeHelper.today(user)
      activity = insert(:planned_activity, planned_date: today, user: user)
      insert(:planned_activity, status: :complete, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with complete activity on the same day" do
      user = insert(:user)
      today = TimeHelper.today(user)
      activity = insert(:planned_activity, status: :complete, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with distance match on the same day" do
      user = insert(:user)
      today = TimeHelper.today(user)
      [activity, _] = insert_pair(:planned_activity, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now, distance: activity.planned_distance}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with duration match on the same day" do
      user = insert(:user)
      today = TimeHelper.today(user)
      [activity, _] = insert_pair(:planned_activity, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now, duration: activity.planned_duration}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end
  end
end

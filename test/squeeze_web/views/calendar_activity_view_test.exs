defmodule SqueezeWeb.CalendarActivityViewTest do
  use SqueezeWeb.ConnCase, async: true

  alias Squeeze.TimeHelper
  alias SqueezeWeb.CalendarActivityView

  describe "#on_date?" do
    test "returns true if planned_date matches date" do
      activity = build(:planned_activity)
      user = activity.user
      date = activity.planned_date
      assert CalendarActivityView.on_date?(user, date, activity)
      refute CalendarActivityView.on_date?(user, Timex.shift(date, days: -1), activity)
    end

    test "returns true if start_at matches date" do
      activity = build(:activity)
      user = activity.user
      date = TimeHelper.to_date(user, activity.start_at)
      assert CalendarActivityView.on_date?(user, date, activity)
      refute CalendarActivityView.on_date?(user, Timex.shift(date, days: -1), activity)
    end
  end
end

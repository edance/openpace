defmodule SqueezeWeb.CalendarViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :calendar_view_case

  alias Squeeze.TimeHelper
  alias SqueezeWeb.CalendarView

  test "title includes sign in" do
    assert CalendarView.title(%{}, %{}) =~ ~r/calendar/i
  end

  test "#prev day 1 day before base" do
    {:ok, date} = Date.new(2018, 12, 5)
    assert CalendarView.prev(date, "day") == "2018-12-04"
  end

  test "#next day is 1 day after base" do
    {:ok, date} = Date.new(2018, 12, 5)
    assert CalendarView.next(date, "day") == "2018-12-06"
  end

  describe "#prev for month" do
    test "returns the previous month" do
      {:ok, date} = Date.new(2018, 1, 5)
      assert CalendarView.prev(date, "month") == "2017-12-05"
    end
  end

  describe "#next for month" do
    test "returns the next month" do
      {:ok, date} = Date.new(2018, 12, 5)
      assert CalendarView.next(date, "month") == "2019-01-05"
    end
  end

  describe "#on_date?" do
    test "returns true if planned_date matches date" do
      activity = build(:planned_activity)
      user = activity.user
      date = activity.planned_date
      assert CalendarView.on_date?(user, date, activity)
      refute CalendarView.on_date?(user, Timex.shift(date, days: -1), activity)
    end

    test "returns true if start_at matches date" do
      activity = build(:activity)
      user = activity.user
      date = TimeHelper.to_date(user, activity.start_at)
      assert CalendarView.on_date?(user, date, activity)
      refute CalendarView.on_date?(user, Timex.shift(date, days: -1), activity)
    end
  end
end

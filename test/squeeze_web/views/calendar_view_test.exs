defmodule SqueezeWeb.CalendarViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :calendar_view_case

  alias Squeeze.TimeHelper
  alias SqueezeWeb.CalendarView

  test "title includes sign in" do
    assert CalendarView.title(%{}, %{}) =~ ~r/calendar/i
  end

  test "#previous_short is 3 days before base" do
    {:ok, date} = Date.new(2018, 12, 5)
    assert CalendarView.previous_short(date) == "2018-12-02"
  end

  test "#next_short is 3 days after base" do
    {:ok, date} = Date.new(2018, 12, 5)
    assert CalendarView.next_short(date) == "2018-12-08"
  end

  describe "#previous_month" do
    test "returns the previous month" do
      {:ok, date} = Date.new(2018, 12, 5)
      assert CalendarView.previous_month(date) == "2018-11-01"
    end

    test "returns the previous month when it is January" do
      {:ok, date} = Date.new(2018, 1, 5)
      assert CalendarView.previous_month(date) == "2017-12-01"
    end
  end

  describe "#next_month" do
    test "returns the next month" do
      {:ok, date} = Date.new(2018, 11, 5)
      assert CalendarView.next_month(date) == "2018-12-01"
    end

    test "returns the previous month when it is December" do
      {:ok, date} = Date.new(2018, 12, 5)
      assert CalendarView.next_month(date) == "2019-01-01"
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

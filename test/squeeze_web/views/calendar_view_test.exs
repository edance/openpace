defmodule SqueezeWeb.CalendarViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :calendar_view_case

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
end

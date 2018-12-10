defmodule SqueezeWeb.CalendarViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :calendar_view_case

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
end

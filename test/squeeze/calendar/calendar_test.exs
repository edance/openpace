defmodule Squeeze.CalendarTest do
  use Squeeze.DataCase

  alias Squeeze.Calendar

  describe "#visible_dates" do
    test "with month that starts on a Monday" do
      {:ok, date} = Date.new(2019, 4, 1)
      range = Calendar.visible_dates(date, "month")
      assert range.first == date
    end

    test "with month that ends on a Monday" do
      {:ok, date} = Date.new(2017, 7, 31)
      range = Calendar.visible_dates(date, "month")
      assert range.last == Date.add(date, 6)
    end

    test "with month includes the days of the prev/next months" do
      {:ok, date} = Date.new(2018, 12, 6)
      {:ok, start_date} = Date.new(2018, 11, 26)
      {:ok, end_date} = Date.new(2019, 1, 6)
      range = Calendar.visible_dates(date, "month")
      assert range.first == start_date
      assert range.last == end_date
    end

    test "with short includes 3 day range" do
      date = Timex.today()
      range = Calendar.visible_dates(date, "short")
      assert range.first == Date.add(date, -1)
      assert range.last == Date.add(date, 1)
    end
  end
end

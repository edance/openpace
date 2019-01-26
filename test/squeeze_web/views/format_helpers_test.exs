defmodule SqueezeWeb.FormatHelpersTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :format_helpers_case

  alias Squeeze.TimeHelper
  alias SqueezeWeb.FormatHelpers

  describe "#format_duration" do
    test "with a nil duration" do
      assert FormatHelpers.format_duration(nil) == nil
    end

    test "with a full duration" do
      duration = 3 * 3600 + 20 * 60
      assert FormatHelpers.format_duration(duration) == "3:20:00"
    end

    test "without an hour" do
      duration = 20 * 60
      assert FormatHelpers.format_duration(duration) == "20:00"
    end

    test "with a minute under 10 and an hour" do
      duration = 3 * 3600 + 9 * 60
      assert FormatHelpers.format_duration(duration) == "3:09:00"
    end

    test "with a minute under 10 and no hour" do
      duration = 9 * 60
      assert FormatHelpers.format_duration(duration) == "9:00"
    end
  end

  describe "#format_distance" do
    test "rounds and adds mi for miles" do
      user_prefs = build(:user_prefs, imperial: true)
      assert FormatHelpers.format_distance(10_000, user_prefs) == "6.22 mi"
    end
  end

  describe "#relative_date" do
    setup [:build_user]

    test "returns today if today", %{user: user, today: today} do
      assert FormatHelpers.relative_date(user, today) == "today"
    end

    test "returns tomorrow if in one day", %{user: user, today: today} do
      date = Timex.shift(today, days: 1)
      assert FormatHelpers.relative_date(user, date) == "tomorrow"
    end

    test "returns day count if less than two weeks",
      %{user: user, today: today} do
      date = Timex.shift(today, days: 14)
      assert FormatHelpers.relative_date(user, date) == "in 14 days"
    end

    test "returns week and day count if over than two weeks",
      %{user: user, today: today} do
      date = Timex.shift(today, days: 15)
      assert FormatHelpers.relative_date(user, date) == "in 2 wks, 1 day"
    end

    test "correctly pluralizes days", %{user: user, today: today} do
      date = Timex.shift(today, days: 16)
      assert FormatHelpers.relative_date(user, date) == "in 2 wks, 2 days"
    end

    test "does not have days if divisible by 7", %{user: user, today: today} do
      date = Timex.shift(today, days: 21)
      assert FormatHelpers.relative_date(user, date) == "in 3 wks"
    end
  end

  describe "#relative_time" do
    test "returns Timex.format with relative" do
      now = Timex.now
      relative_time = FormatHelpers.relative_time(now)
      assert relative_time == Timex.format!(now, "{relative}", :relative)
    end
  end

  describe "#format_pace" do
    setup [:build_user_prefs, :build_activity]

    test "with a valid distance", %{activity: activity, user_prefs: user_prefs} do
      assert FormatHelpers.format_pace(activity, user_prefs) == "7:00/mi"
    end

    test "with valid distance and metric user_prefs",
      %{activity: activity, user_prefs: user_prefs} do
      user_prefs = %{user_prefs | imperial: false}
      assert FormatHelpers.format_pace(activity, user_prefs) == "4:20/km"
    end

    test "with a distance of 0", %{activity: activity, user_prefs: user_prefs} do
      activity = %{activity | distance: 0}
      assert FormatHelpers.format_pace(activity, user_prefs) == "N/A"
    end
  end

  defp build_user(_) do
    user = build(:user)
    today = TimeHelper.today(user)
    {:ok, user: user, today: today}
  end

  defp build_user_prefs(_) do
    {:ok, user_prefs: build(:user_prefs)}
  end

  defp build_activity(_) do
    attrs = %{
      distance: 2 * 1609, # 2 miles in meters
      duration: 14 * 60 # 14 minutes in seconds
    }
    {:ok, activity: build(:activity, attrs)}
  end
end

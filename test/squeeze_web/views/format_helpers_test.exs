defmodule SqueezeWeb.FormatHelpersTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :format_helpers_case

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

  describe "#relative_time" do
    test "returns Timex.format with relative" do
      now = Timex.now
      relative_time = FormatHelpers.relative_time(now)
      assert relative_time == Timex.format!(now, "{relative}", :relative)
    end
  end

  describe "#format_pace" do
    test "with a valid distance" do
      distance = 2 * 1609 # 2 miles in meters
      duration = 14 * 60 # 14 minutes in seconds
      pace_str = FormatHelpers.format_pace(duration, distance)
      assert pace_str == "7:00 min/mile"
    end

    test "with an invalid distance > 0" do
      distance = 1 # 1 meter
      duration = 14 * 60 # 14 minutes in seconds
      pace_str = FormatHelpers.format_pace(duration, distance)
      assert pace_str == ""
    end

    test "with a distance of 0" do
      distance = 0 # 1 meter
      duration = 30 * 60 # 30 minutes in seconds
      pace_str = FormatHelpers.format_pace(duration, distance)
      assert pace_str == ""
    end
  end
end

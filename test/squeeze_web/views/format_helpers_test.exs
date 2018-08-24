defmodule SqueezeWeb.FormatHelpersTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :format_helpers_case

  describe "#format_duration" do
    test "with a full duration" do
      duration = %{ total: 3 * 3600 + 20 * 60 }
      assert SqueezeWeb.FormatHelpers.format_duration(duration) == "3:20:00"
    end

    test "without an hour" do
      duration = %{ total: 20 * 60 }
      assert SqueezeWeb.FormatHelpers.format_duration(duration) == "20:00"
    end

    test "with a minute under 10 and an hour" do
      duration = %{ total: 3 * 3600 + 9 * 60 }
      assert SqueezeWeb.FormatHelpers.format_duration(duration) == "3:09:00"
    end

    test "with a minute under 10 and no hour" do
      duration = %{ total: 9 * 60 }
      assert SqueezeWeb.FormatHelpers.format_duration(duration) == "9:00"
    end
  end
end

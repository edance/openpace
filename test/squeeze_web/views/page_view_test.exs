defmodule SqueezeWeb.PageViewTest do
  use SqueezeWeb.ConnCase, async: true

  alias SqueezeWeb.PageView

  describe "#distances" do
    test "returns a list of tuples of names and distances" do
      {option, value} = PageView.distances
      |> List.first()
      assert is_binary(option)
      assert is_integer(value)
    end
  end

  test "terms helper methods" do
    assert PageView.company_name == "Squeeze.Run"
    assert PageView.website_name == "Squeeze.Run"
    assert PageView.website_url == "https://squeeze.run"
  end
end

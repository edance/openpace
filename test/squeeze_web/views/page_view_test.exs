defmodule SqueezeWeb.PageViewTest do
  use SqueezeWeb.ConnCase, async: true

  alias SqueezeWeb.PageView

  test "terms title" do
    assert PageView.title("terms.html", %{}) == "Terms and Conditions"
  end

  test "privacy policy page title" do
    assert PageView.title("privacy_policy.html", %{}) == "Privacy Policy"
  end

  test "terms helper methods" do
    assert PageView.company_name == "Squeeze.Run"
    assert PageView.website_name == "Squeeze.Run"
    assert PageView.website_url == "https://squeeze.run"
  end
end

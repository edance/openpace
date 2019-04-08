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
    assert PageView.website_name == "OpenPace.co"
    assert PageView.website_url == "https://www.openpace.co"
  end
end

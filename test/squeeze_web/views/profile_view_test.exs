defmodule SqueezeWeb.ProfileViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :profile_view_case

  alias Squeeze.Accounts.User
  alias SqueezeWeb.ProfileView

  test "title includes profile" do
    assert ProfileView.title(%{}, %{}) =~ ~r/profile/i
  end

  test "#full_name is User.full_name" do
    user = build(:user)
    assert ProfileView.full_name(user) == User.full_name(user)
  end

  describe "#hometown" do
    test "includes city and state" do
      user = build(:user, %{city: "Traverse City", state: "MI"})
      assert ProfileView.hometown(user) == "Traverse City, MI"
    end
  end
end

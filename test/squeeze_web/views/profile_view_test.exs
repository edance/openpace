defmodule SqueezeWeb.ProfileViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :profile_view_case

  alias SqueezeWeb.ProfileView

  test "title includes profile" do
    assert ProfileView.title(%{}, %{}) =~ ~r/profile/i
  end
end

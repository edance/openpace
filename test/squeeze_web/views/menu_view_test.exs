defmodule SqueezeWeb.MenuViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :menu_view_case

  alias Squeeze.Accounts.User
  alias SqueezeWeb.MenuView

  test "#full_name is User.full_name" do
    user = build(:user)
    assert MenuView.full_name(user) == User.full_name(user)
  end

  test "#authenticated? is User.onboarded?" do
    user = build(:user)
    assert MenuView.authenticated?(user) == User.onboarded?(user)
  end
end

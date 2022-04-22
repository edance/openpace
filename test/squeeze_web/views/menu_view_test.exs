defmodule SqueezeWeb.MenuViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :menu_view_case

  alias Squeeze.Accounts.User
  alias SqueezeWeb.MenuView

  test "#authenticated? is User.onboarded?" do
    user = build(:user)
    assert MenuView.authenticated?(user) == User.onboarded?(user)
  end
end

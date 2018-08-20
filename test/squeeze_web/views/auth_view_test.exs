defmodule SqueezeWeb.AuthViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :auth_view_case

  test "title includes sign in" do
    assert SqueezeWeb.AuthView.title(%{}, %{}) =~ ~r/Sign in/
  end
end

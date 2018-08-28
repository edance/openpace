defmodule SqueezeWeb.AuthViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :auth_view_case

  alias SqueezeWeb.AuthView

  test "title includes sign in" do
    assert AuthView.title(%{}, %{}) =~ ~r/Sign in/
  end
end

defmodule SqueezeWeb.ActivityViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :activity_view_case

  alias SqueezeWeb.ActivityView

  test "title includes sign in" do
    assert ActivityView.title(%{}, %{}) =~ "Activities"
  end
end

defmodule SqueezeWeb.PlanViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :plan_view_case

  alias SqueezeWeb.PlanView

  test "title includes sign in" do
    assert PlanView.title(%{}, %{}) =~ "Build your training plan"
  end
end

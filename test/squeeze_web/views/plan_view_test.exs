defmodule SqueezeWeb.PlanViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :plan_view_case

  alias SqueezeWeb.PlanView

  test "title includes sign in" do
    assert PlanView.title(%{}, %{}) =~ "Build your training plan"
  end

  test "day_name contains the date" do
    {:ok, date} = Date.new(2018, 9, 9) # This is a Sunday
    assert PlanView.day_name(date) == "Sunday"
  end
end

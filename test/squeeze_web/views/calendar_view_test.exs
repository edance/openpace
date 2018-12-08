defmodule SqueezeWeb.CalendarViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :calendar_view_case

  alias SqueezeWeb.CalendarView

  test "title includes sign in" do
    assert CalendarView.title(%{}, %{}) =~ ~r/calendar/i
  end
end

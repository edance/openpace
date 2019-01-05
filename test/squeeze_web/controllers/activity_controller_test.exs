defmodule SqueezeWeb.ActivityControllerTest do
  use SqueezeWeb.ConnCase

  test "lists all activities on index", %{conn: conn} do
    conn = get conn, activity_path(conn, :index)
    assert html_response(conn, 200) =~ "Activities"
  end

  describe "GET show" do
    test "renders the activity", %{conn: conn} do
      activity = insert(:activity)
      conn = get conn, activity_path(conn, :show, activity)
      assert html_response(conn, 200) =~ activity.name
    end
  end
end

defmodule SqueezeWeb.ActivityControllerTest do
  use SqueezeWeb.ConnCase

  test "lists all activities on index", %{conn: conn} do
    conn = get(conn, activity_path(conn, :index))
    assert html_response(conn, 200) =~ "Activities"
  end

  describe "PATCH mark_complete" do
    test "Success message is displayed when activity is marked as completed", %{
      conn: conn,
      user: user
    } do
      activity = insert(:activity, user: user)
      conn = patch(conn, activity_mark_complete_path(conn, :mark_complete, activity.id))
      assert get_flash(conn, :info) == "Activity completed!"
    end
  end
end

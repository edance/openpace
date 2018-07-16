defmodule SqueezeWeb.ActivityControllerTest do
  use SqueezeWeb.ConnCase

  @tag :as_user
  test "lists all activities on index", %{conn: conn} do
    conn = get conn, activity_path(conn, :index)
    assert html_response(conn, 200) =~ "Activities"
  end
end

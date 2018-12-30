defmodule SqueezeWeb.DashboardControllerTest do
  use SqueezeWeb.ConnCase

  test "index redirects to overview", %{conn: conn} do
    conn = get(conn, dashboard_path(conn, :index))
    assert redirected_to(conn) == overview_path(conn, :index)
  end
end

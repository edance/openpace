defmodule SqueezeWeb.PageControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    @tag :guest_user
    test "as a guest user", %{conn: conn} do
      conn = conn
      |> get("/")
      assert html_response(conn, 200) =~ "Squeeze"
    end

    test "as a complete user", %{conn: conn} do
      conn = conn
      |> get("/")
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end
end

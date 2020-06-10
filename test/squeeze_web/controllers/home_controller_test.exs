defmodule SqueezeWeb.HomeControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    @tag :no_user
    test "as a visitor", %{conn: conn} do
      conn = conn
      |> get("/")
      assert redirected_to(conn) == session_path(conn, :new)
    end

    test "as a complete user", %{conn: conn} do
      conn = conn
      |> get("/")
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end
end

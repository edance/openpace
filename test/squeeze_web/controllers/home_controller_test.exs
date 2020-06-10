defmodule SqueezeWeb.HomeControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    test "as a registered user", %{conn: conn} do
      conn = conn
      |> get("/")
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end
end

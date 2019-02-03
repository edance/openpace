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

  test "GET /privacy returns the privacy policy", %{conn: conn} do
    conn = conn
    |> get("/privacy")

    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  test "GET /terms returns the terms and conditions", %{conn: conn} do
    conn = conn
    |> get("/terms")

    assert html_response(conn, 200) =~ "Terms and Conditions"
  end
end

defmodule SqueezeWeb.CalendarControllerTest do
  use SqueezeWeb.ConnCase

  describe "#index" do
    test "on mobile redirects to short calendar", %{conn: conn} do
      user_agent = "Mobile Safari/537.36"
      conn = conn
      |> put_req_header("user-agent", user_agent)
      |> get(calendar_path(conn, :index))
      assert redirected_to(conn) == calendar_path(conn, :show, "short")
    end

    test "on non-mobile redirects to monthly calendar", %{conn: conn} do
      user_agent = "Chrome/70.0.3538.110"
      conn = conn
      |> put_req_header("user-agent", user_agent)
      |> get(calendar_path(conn, :index))
      assert redirected_to(conn) == calendar_path(conn, :show, "month")
    end
  end

  describe "#show short" do
    test "without date params renders correctly", %{conn: conn} do
      conn = conn
      |> get(calendar_path(conn, :show, "short"))
      assert html_response(conn, 200)
    end

    test "with date params renders correctly", %{conn: conn} do
      conn = conn
      |> get(calendar_path(conn, :show, "short", date: "2018-01-01"))
      assert html_response(conn, 200)
    end
  end

  describe "#show month" do
    test "without date params renders correctly", %{conn: conn} do
      conn = conn
      |> get(calendar_path(conn, :show, "month"))
      assert html_response(conn, 200)
    end

    test "with date params renders correctly", %{conn: conn} do
      conn = conn
      |> get(calendar_path(conn, :show, "month", date: "2018-01-01"))
      assert html_response(conn, 200)
    end

    test "with invalid date renders today", %{conn: conn} do
      conn = conn
      |> get(calendar_path(conn, :show, "month", date: "abcdef"))
      assert html_response(conn, 200)
    end
  end

  test "with invalid calendar type", %{conn: conn} do
    conn = conn
    |> get(calendar_path(conn, :show, "abcd"))
    assert html_response(conn, 404)
  end
end

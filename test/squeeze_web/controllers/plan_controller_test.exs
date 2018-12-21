defmodule SqueezeWeb.PlanControllerTest do
  use SqueezeWeb.ConnCase

  import Plug.Test

  test "index redirects to the first step", %{conn: conn} do
    conn = get(conn, "/dashboard/plan")
    assert redirected_to(conn) == plan_path(conn, :step, "weeks")
  end

  describe "#step" do
    test "valid step name", %{conn: conn} do
      conn = get(conn, "/dashboard/plan/weeks")
      assert html_response(conn, 200) =~ "weeks"
    end

    test "invalid step name", %{conn: conn} do
      conn = get(conn, "/dashboard/plan/abcd")
      assert html_response(conn, 404) =~ "not found"
    end
  end

  describe "#update" do
    test "weeks updates session and redirects", %{conn: conn} do
      conn = post(conn, "/dashboard/plan/weeks", weeks: "18")
      assert get_session(conn, :weeks) == 18
      assert redirected_to(conn) == plan_path(conn, :step, "start")
    end

    test "start updates session and redirects", %{conn: conn} do
      date = "2018-01-01"
      conn = post(conn, "/dashboard/plan/start", start_at: date)
      assert get_session(conn, :start_at) == Timex.parse!(date, "{YYYY}-{0M}-{0D}")
      assert redirected_to(conn) == plan_path(conn, :new, 1)
    end

    test "with an invalid date sets session to today", %{conn: conn} do
      date = "invalid"
      conn = post(conn, "/dashboard/plan/start", start_at: date)
      assert get_session(conn, :start_at) == Timex.today
    end
  end

  describe "#new" do
    test "includes the week number", %{conn: conn} do
      conn = conn
      |> init_test_session(start_at: Timex.today)
      |> get("/dashboard/plan/weeks/2")
      assert html_response(conn, 200) =~ ~r/week 2/i
    end
  end
end

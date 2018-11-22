defmodule SqueezeWeb.WizardControllerTest do
  use SqueezeWeb.ConnCase

  test "index redirects to the first step", %{conn: conn} do
    conn = get(conn, "/quiz")
    assert redirected_to(conn) == page_path(conn, :index)
  end

  # test "index redirects to the current step if session", %{conn: conn} do
  #   step = "duration"
  #   conn = conn
  #   |> put_session(:current_step, step)
  #   |> get("/quiz")
  #   assert redirected_to(conn) == wizard_path(conn, :step, step)
  # end

  describe "#step" do
    test "valid step name", %{conn: conn} do
      conn = get(conn, "/quiz/duration")
      assert html_response(conn, 200) =~ "time"
    end

    test "invalid step name", %{conn: conn} do
      conn = get(conn, "/quiz/abcd")
      assert html_response(conn, 404) =~ "not found"
    end
  end

  # describe "#update" do
  #   test "weeks updates session and redirects", %{conn: conn} do
  #     conn = post(conn, "/quiz/duration", weeks: 12345)
  #     assert get_session(conn, :weeks) == 18
  #     assert redirected_to(conn) == plan_path(conn, :step, "start")
  #   end

  #   test "start updates session and redirects", %{conn: conn} do
  #     date = "2018-01-01"
  #     conn = post(conn, "/dashboard/plan/start", start_at: date)
  #     assert get_session(conn, :start_at) == Timex.parse!(date, "{YYYY}-{0M}-{0D}")
  #     assert redirected_to(conn) == plan_path(conn, :new, 1)
  #   end
  # end
end

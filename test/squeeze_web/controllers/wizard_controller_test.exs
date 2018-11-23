defmodule SqueezeWeb.WizardControllerTest do
  use SqueezeWeb.ConnCase

  test "index redirects to the first step", %{conn: conn} do
    conn = get(conn, wizard_path(conn, :index))
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

  describe "#update" do
    test "redirects when data is valid", %{conn: conn} do
      step = "distance"
      next_step = "race-date"
      conn = put conn, wizard_path(conn, :update, step), user_prefs: %{distance: 1}
      assert redirected_to(conn) == wizard_path(conn, :step, next_step)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      step = "distance"
      conn = put conn, wizard_path(conn, :update, step), user_prefs: %{distance: nil}
      assert html_response(conn, 200) =~ "Choose a distance"
    end
  end
end

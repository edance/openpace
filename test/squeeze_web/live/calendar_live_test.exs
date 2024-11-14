defmodule SqueezeWeb.CalendarLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Squeeze.Factory

  alias Faker.Date

  describe "calendar display" do
    test "displays current month by default", %{conn: conn} do
      {:ok, _live, html} = live(conn, Routes.calendar_path(conn, :index))

      current_month = Timex.format!(Timex.today(), "%B", :strftime)
      assert html =~ current_month
    end

    test "can navigate to next month", %{conn: conn} do
      {:ok, live, _html} = live(conn, Routes.calendar_path(conn, :index))

      next_month =
        Timex.today()
        |> Timex.shift(months: 1)
        |> Timex.format!("%B", :strftime)

      html =
        live
        |> element("a", "Next")
        |> render_click()

      assert html =~ next_month
    end

    test "can navigate to previous month", %{conn: conn} do
      {:ok, live, _html} = live(conn, Routes.calendar_path(conn, :index))

      prev_month =
        Timex.today()
        |> Timex.shift(months: -1)
        |> Timex.format!("%B", :strftime)

      html =
        live
        |> element("a", "Previous")
        |> render_click()

      assert html =~ prev_month
    end
  end

  describe "activities" do
    test "displays activities on correct dates", %{conn: conn, user: user} do
      activity = insert(:activity, user: user, start_at: Timex.now())
      {:ok, _live, html} = live(conn, Routes.calendar_path(conn, :index))

      assert html =~ activity.name
    end
  end

  describe "race goals" do
    test "displays race goals on calendar", %{conn: conn, user: user} do
      race_goal = insert(:race_goal, user: user, race_date: Timex.today())
      {:ok, _live, html} = live(conn, Routes.calendar_path(conn, :index))

      assert html =~ race_goal.race_name
    end

    test "displays multiple events on same day", %{conn: conn, user: user} do
      date = Timex.today()
      activity = insert(:activity, user: user, start_at: Timex.now())
      race_goal = insert(:race_goal, user: user, race_date: date)

      {:ok, _live, html} = live(conn, Routes.calendar_path(conn, :index))

      assert html =~ activity.name
      assert html =~ race_goal.race_name
    end
  end
end

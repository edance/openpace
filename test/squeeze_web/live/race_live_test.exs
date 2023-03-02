defmodule SqueezeWeb.RaceLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Squeeze.Factory

  alias Faker.Date

  describe "Index" do
    test "lists past races", %{conn: conn, user: user} do
      race_goal = insert(:race_goal, user: user, race_date: Date.backward(10))
      {:ok, _index_live, html} = live(conn, Routes.race_path(conn, :index))

      assert html =~ race_goal.race_name
    end

    test "lists upcoming races", %{conn: conn, user: user} do
      race_goal = insert(:race_goal, user: user, race_date: Date.forward(10))
      {:ok, _index_live, html} = live(conn, Routes.race_path(conn, :index))

      assert html =~ race_goal.race_name
    end
  end

  describe "Show" do
    test "displays race goal with duration", %{conn: conn, user: user} do
      race_goal = insert(:race_goal, user: user)
      {:ok, _show_live, html} = live(conn, Routes.race_path(conn, :show, race_goal.slug))

      assert html =~ race_goal.race_name
    end

    test "displays race goal with just finish", %{conn: conn, user: user} do
      race_goal = insert(:race_goal, user: user) |> just_finish_goal()
      {:ok, _show_live, html} = live(conn, Routes.race_path(conn, :show, race_goal.slug))

      assert html =~ race_goal.race_name
    end
  end
end

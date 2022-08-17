defmodule SqueezeWeb.RaceLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Squeeze.Factory

  defp create_race(%{user: user}) do
    race_goal = insert(:race_goal, user: user)
    just_finish_goal = insert(:race_goal, user: user) |> just_finish_goal()
    %{race_goal: race_goal, just_finish_goal: just_finish_goal}
  end

  describe "Index" do
    setup [:create_race]

    test "lists all races", %{conn: conn, race_goal: race_goal} do
      {:ok, _index_live, html} = live(conn, Routes.race_path(conn, :index))

      assert html =~ race_goal.race.name
    end
  end

  describe "Show" do
    setup [:create_race]

    test "displays race goal with duration", %{conn: conn, race_goal: race_goal} do
      {:ok, _show_live, html} = live(conn, Routes.race_path(conn, :show, race_goal.slug))

      assert html =~ race_goal.race.name
    end

    test "displays race goal with just finish", %{conn: conn, just_finish_goal: just_finish_goal} do
      {:ok, _show_live, html} = live(conn, Routes.race_path(conn, :show, just_finish_goal.slug))

      assert html =~ just_finish_goal.race.name
    end
  end
end

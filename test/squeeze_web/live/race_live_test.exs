defmodule SqueezeWeb.RaceLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Squeeze.RacesFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_race(_) do
    race = race_fixture()
    %{race: race}
  end

  describe "Index" do
    setup [:create_race]

    test "lists all races", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.race_index_path(conn, :index))

      assert html =~ "Listing Races"
    end

    test "saves new race", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.race_index_path(conn, :index))

      assert index_live |> element("a", "New Race") |> render_click() =~
               "New Race"

      assert_patch(index_live, Routes.race_index_path(conn, :new))

      assert index_live
             |> form("#race-form", race: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#race-form", race: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.race_index_path(conn, :index))

      assert html =~ "Race created successfully"
    end

    test "updates race in listing", %{conn: conn, race: race} do
      {:ok, index_live, _html} = live(conn, Routes.race_index_path(conn, :index))

      assert index_live |> element("#race-#{race.id} a", "Edit") |> render_click() =~
               "Edit Race"

      assert_patch(index_live, Routes.race_index_path(conn, :edit, race))

      assert index_live
             |> form("#race-form", race: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#race-form", race: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.race_index_path(conn, :index))

      assert html =~ "Race updated successfully"
    end

    test "deletes race in listing", %{conn: conn, race: race} do
      {:ok, index_live, _html} = live(conn, Routes.race_index_path(conn, :index))

      assert index_live |> element("#race-#{race.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#race-#{race.id}")
    end
  end

  describe "Show" do
    setup [:create_race]

    test "displays race", %{conn: conn, race: race} do
      {:ok, _show_live, html} = live(conn, Routes.race_show_path(conn, :show, race))

      assert html =~ "Show Race"
    end

    test "updates race within modal", %{conn: conn, race: race} do
      {:ok, show_live, _html} = live(conn, Routes.race_show_path(conn, :show, race))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Race"

      assert_patch(show_live, Routes.race_show_path(conn, :edit, race))

      assert show_live
             |> form("#race-form", race: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#race-form", race: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.race_show_path(conn, :show, race))

      assert html =~ "Race updated successfully"
    end
  end
end

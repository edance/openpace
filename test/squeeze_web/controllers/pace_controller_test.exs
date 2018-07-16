defmodule SqueezeWeb.PaceControllerTest do
  use SqueezeWeb.ConnCase

  @valid_attrs %{name: "some name", offset: 42}
  @invalid_attrs %{name: nil, offset: nil}

  @tag :as_user
  test "lists all paces on index", %{conn: conn} do
    pace = insert(:pace, user: conn.assigns.current_user)

    conn = get(conn, pace_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Paces/
    assert String.contains?(conn.resp_body, pace.name)
  end

  @tag :as_user
  test "renders form to create new pace", %{conn: conn} do
    conn = get(conn, pace_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/New/
  end

  @tag :as_user
  test "creates pace and redirects", %{conn: conn} do
    conn = post(conn, pace_path(conn, :create), pace: @valid_attrs)

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == pace_path(conn, :show, id)
  end

  @tag :as_user
  test "does not create with invalid attributes", %{conn: conn} do
    conn = post(conn, pace_path(conn, :create), pace: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/New/
  end

  @tag :as_user
  test "renders form for editing chosen pace", %{conn: conn} do
    pace = insert(:pace, user: conn.assigns.current_user)
    conn = get conn, pace_path(conn, :edit, pace)
    assert html_response(conn, 200) =~ "Edit Pace"
  end

  @tag :as_user
  test "updates pace and redirects", %{conn: conn} do
    pace = insert(:pace, user: conn.assigns.current_user)
    conn = put conn, pace_path(conn, :update, pace), pace: @valid_attrs
    assert redirected_to(conn) == pace_path(conn, :show, pace)
  end

  @tag :as_user
  test "deletes chosen pace on delete", %{conn: conn} do
    pace = insert(:pace, user: conn.assigns.current_user)
    conn = delete conn, pace_path(conn, :delete, pace)
    assert redirected_to(conn) == pace_path(conn, :index)
  end
end

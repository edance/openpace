defmodule SqueezeWeb.GoalControllerTest do
  use SqueezeWeb.ConnCase

  @valid_attrs %{date: ~D[2010-04-17], distance: 120.5, duration: 42, name: "some name"}
  @invalid_attrs %{date: nil, distance: nil, duration: nil, name: nil}

  @tag :as_user
  test "lists all goals on index", %{conn: conn} do
    goal = insert(:goal, user: conn.assigns.current_user)

    conn = get(conn, goal_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Goals/
    assert String.contains?(conn.resp_body, goal.name)
  end

  @tag :as_user
  test "renders form to create new goal", %{conn: conn} do
    conn = get(conn, goal_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/New/
  end

  @tag :as_user
  test "creates goal and redirects", %{conn: conn} do
    conn = post(conn, goal_path(conn, :create), goal: @valid_attrs)

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == goal_path(conn, :show, id)
  end

  @tag :as_user
  test "does not create with invalid attributes", %{conn: conn} do
    conn = post(conn, goal_path(conn, :create), goal: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/New/
  end

  @tag :as_user
  test "renders form for editing chosen goal", %{conn: conn} do
    goal = insert(:goal, user: conn.assigns.current_user)
    conn = get conn, goal_path(conn, :edit, goal)
    assert html_response(conn, 200) =~ "Edit Goal"
  end

  @tag :as_user
  test "updates goal and redirects", %{conn: conn} do
    goal = insert(:goal, user: conn.assigns.current_user)
    conn = put conn, goal_path(conn, :update, goal), goal: @valid_attrs
    assert redirected_to(conn) == goal_path(conn, :show, goal)
  end

  @tag :as_user
  test "deletes chosen goal on delete", %{conn: conn} do
    goal = insert(:goal, user: conn.assigns.current_user)
    conn = delete conn, goal_path(conn, :delete, goal)
    assert redirected_to(conn) == goal_path(conn, :index)
  end
end

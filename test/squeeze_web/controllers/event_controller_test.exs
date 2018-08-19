defmodule SqueezeWeb.EventControllerTest do
  use SqueezeWeb.ConnCase

  @valid_attrs %{cooldown: true, date: ~D[2010-04-17], distance: 120.5, name: "some name", warmup: true}
  @invalid_attrs %{cooldown: nil, date: nil, distance: nil, name: nil, warmup: nil}

  @tag :as_user
  test "renders form to create new event", %{conn: conn} do
    conn = get(conn, event_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/New/
  end

  @tag :as_user
  test "creates event and redirects", %{conn: conn} do
    conn = post(conn, event_path(conn, :create), event: @valid_attrs)

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == event_path(conn, :show, id)
  end

  @tag :as_user
  test "does not create with invalid attributes", %{conn: conn} do
    conn = post(conn, event_path(conn, :create), event: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/New/
  end

  @tag :as_user
  test "renders form for editing chosen event", %{conn: conn} do
    event = insert(:event, user: conn.assigns.current_user)
    conn = get conn, event_path(conn, :edit, event)
    assert html_response(conn, 200) =~ "Edit Event"
  end

  @tag :as_user
  test "updates event and redirects", %{conn: conn} do
    event = insert(:event, user: conn.assigns.current_user)
    conn = put conn, event_path(conn, :update, event), event: %{cooldown: false}
    assert redirected_to(conn) == event_path(conn, :show, event)
  end

  @tag :as_user
  test "deletes chosen event on delete", %{conn: conn} do
    event = insert(:event, user: conn.assigns.current_user)
    conn = delete conn, event_path(conn, :delete, event)
    assert redirected_to(conn) == event_path(conn, :index)
  end
end

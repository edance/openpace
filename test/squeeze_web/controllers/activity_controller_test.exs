defmodule SqueezeWeb.ActivityControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Dashboard

  test "lists all activities on index", %{conn: conn} do
    conn = get conn, activity_path(conn, :index)
    assert html_response(conn, 200) =~ "Activities"
  end

  describe "GET show" do
    test "renders the activity", %{conn: conn, user: user} do
      activity = insert(:activity, user: user)
      conn = get conn, activity_path(conn, :show, activity)
      assert html_response(conn, 200) =~ activity.name
    end
  end

  describe "GET new" do
    test "renders form", %{conn: conn} do
      conn = get conn, activity_path(conn, :new)
      assert html_response(conn, 200) =~ "New Activity"
    end
  end

  describe "POST create" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      attrs = params_for(:activity, %{name: "some name"})
      conn = post conn, activity_path(conn, :create), activity: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == activity_path(conn, :show, id)
      assert Dashboard.get_activity!(user, id).name == "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      attrs = %{name: nil}
      conn = post conn, activity_path(conn, :create), activity: attrs
      assert html_response(conn, 422) =~ "New Activity"
    end
  end
end

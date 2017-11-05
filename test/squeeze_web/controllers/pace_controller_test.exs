defmodule SqueezeWeb.PaceControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Dashboard

  @create_attrs %{name: "some name", offset: 42}
  @update_attrs %{name: "some updated name", offset: 43}
  @invalid_attrs %{name: nil, offset: nil}

  def fixture(:pace) do
    {:ok, pace} = Dashboard.create_pace(@create_attrs)
    pace
  end

  describe "index" do
    test "lists all paces", %{conn: conn} do
      conn = get conn, pace_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Paces"
    end
  end

  describe "new pace" do
    test "renders form", %{conn: conn} do
      conn = get conn, pace_path(conn, :new)
      assert html_response(conn, 200) =~ "New Pace"
    end
  end

  describe "create pace" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, pace_path(conn, :create), pace: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == pace_path(conn, :show, id)

      conn = get conn, pace_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Pace"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, pace_path(conn, :create), pace: @invalid_attrs
      assert html_response(conn, 200) =~ "New Pace"
    end
  end

  describe "edit pace" do
    setup [:create_pace]

    test "renders form for editing chosen pace", %{conn: conn, pace: pace} do
      conn = get conn, pace_path(conn, :edit, pace)
      assert html_response(conn, 200) =~ "Edit Pace"
    end
  end

  describe "update pace" do
    setup [:create_pace]

    test "redirects when data is valid", %{conn: conn, pace: pace} do
      conn = put conn, pace_path(conn, :update, pace), pace: @update_attrs
      assert redirected_to(conn) == pace_path(conn, :show, pace)

      conn = get conn, pace_path(conn, :show, pace)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, pace: pace} do
      conn = put conn, pace_path(conn, :update, pace), pace: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Pace"
    end
  end

  describe "delete pace" do
    setup [:create_pace]

    test "deletes chosen pace", %{conn: conn, pace: pace} do
      conn = delete conn, pace_path(conn, :delete, pace)
      assert redirected_to(conn) == pace_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, pace_path(conn, :show, pace)
      end
    end
  end

  defp create_pace(_) do
    pace = fixture(:pace)
    {:ok, pace: pace}
  end
end

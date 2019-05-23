defmodule SqueezeWeb.HomeControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    @tag :guest_user
    test "as a guest user", %{conn: conn} do
      conn = conn
      |> get("/")
      assert html_response(conn, 200) =~ "OpenPace"
    end

    test "as a complete user", %{conn: conn} do
      conn = conn
      |> get("/")
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end

  describe "POST /" do
    @tag :guest_user
    test "with a valid email address", %{conn: conn} do
      conn = conn
      |> post("/", subscription: %{"email" => "test@test.com"})

      assert get_flash(conn, :info) == "Thanks for signing up!"
      assert redirected_to(conn) == home_path(conn, :index)
    end

    @tag :guest_user
    test "with an invalid email", %{conn: conn} do
      conn = conn
      |> post("/", subscription: %{"email" => "test"})

      assert get_flash(conn, :error) == "Invalid email address"
    end
  end
end

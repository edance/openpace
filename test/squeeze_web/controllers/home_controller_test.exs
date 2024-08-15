defmodule SqueezeWeb.HomeControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    test "as a registered user", %{conn: conn} do
      conn =
        conn
        |> get("/")

      assert redirected_to(conn) == overview_path(conn, :index)
    end
  end

  describe "POST /" do
    @tag :no_user
    test "with a valid email address", %{conn: conn} do
      conn =
        conn
        |> post("/", subscription: %{"email" => "test@test.com"})

      assert get_flash(conn, :info) == "Thanks for signing up!"
      assert redirected_to(conn) == home_path(conn, :index)
    end

    @tag :no_user
    test "with an invalid email", %{conn: conn} do
      conn =
        conn
        |> post("/", subscription: %{"email" => "test"})

      assert get_flash(conn, :error) == "Invalid email address"
    end
  end
end

defmodule SqueezeWeb.OnboardControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    @tag :guest_user
    test "as a guest user", %{conn: conn} do
      conn = conn
      |> get("/onboard")
      assert html_response(conn, 200) =~ "What race are you training for"
    end

    test "as a registered user", %{conn: conn} do
      conn = conn
      |> get("/onboard")
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end
end

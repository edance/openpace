defmodule SqueezeWeb.OnboardControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    @tag :no_user
    test "as a visitor", %{conn: conn} do
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

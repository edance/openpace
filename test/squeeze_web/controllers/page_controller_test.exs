defmodule SqueezeWeb.PageControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    test "as a guest user", %{conn: conn} do
      user = insert(:user, user_prefs: %{})
      conn = conn
      |> assign(:current_user, user)
      |> get("/")
      assert html_response(conn, 200) =~ "Squeeze"
    end

    test "as a complete user", %{conn: conn} do
      conn = conn
      |> get("/")
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end
end

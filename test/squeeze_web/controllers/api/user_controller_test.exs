defmodule SqueezeWeb.Api.UserControllerTest do
  use SqueezeWeb.ConnCase

  describe "#create" do
    @tag :no_user
    test "returns an auth token and the user", %{conn: conn} do
      conn = conn |> post(api_user_path(conn, :signup))
      conn = conn
      |> post("/")
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end
end

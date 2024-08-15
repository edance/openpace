defmodule SqueezeWeb.ExportControllerTest do
  use SqueezeWeb.ConnCase

  import Squeeze.Factory

  describe "GET #activities" do
    test "with api_enabled returns activities in csv", %{conn: conn} do
      %{user: user} = insert(:user_prefs_with_user, api_enabled: true)
      insert_pair(:activity, user: user)
      conn = get(conn, export_path(conn, :activities, user.slug))

      # headers are included
      assert response(conn, 200) =~ "distance"
      assert response_content_type(conn, :csv) =~ "charset=utf-8"
    end

    test "with api_enabled: false returns status 401", %{conn: conn, user: user} do
      conn = get(conn, export_path(conn, :activities, user.slug))

      assert response(conn, 401)
    end
  end
end

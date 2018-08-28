defmodule SqueezeWeb.AuthControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Guardian.Plug

  test "renders login page", %{conn: conn} do
    conn = get(conn, auth_path(conn, :login))
    assert html_response(conn, 200) =~ ~r/Welcome/
  end

  test "request with strava redirects to strava url", %{conn: conn} do
    conn = get(conn, auth_path(conn, :request, "strava"))
    assert redirected_to(conn) =~ ~r/https:\/\/www.strava.com/
  end

  test "logs out user on delete", %{conn: conn} do
    conn = delete conn, auth_path(conn, :delete)
    user = Plug.current_resource(conn)
    assert user == nil
  end
end

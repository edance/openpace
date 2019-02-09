defmodule SqueezeWeb.SessionControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Guardian.Plug

  test "renders login page", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/Welcome/
  end

  test "logs out user on delete", %{conn: conn} do
    conn = delete conn, session_path(conn, :delete)
    user = Plug.current_resource(conn)
    assert user == nil
  end
end

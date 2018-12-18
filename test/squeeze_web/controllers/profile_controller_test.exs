defmodule SqueezeWeb.ProfileControllerTest do
  use SqueezeWeb.ConnCase

  test "#edit includes profile", %{conn: conn} do
    conn = conn
    |> get(profile_path(conn, :edit))
    assert html_response(conn, 200) =~ ~r/profile/i
  end
end

defmodule SqueezeWeb.ProfileControllerTest do
  use SqueezeWeb.ConnCase

  test "#show includes profile", %{conn: conn} do
    conn = conn
    |> get(profile_path(conn, :show))
    assert html_response(conn, 200) =~ ~r/profile/i
  end
end

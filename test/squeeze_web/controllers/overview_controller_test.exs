defmodule SqueezeWeb.OverviewControllerTest do
  use SqueezeWeb.ConnCase

  test "#show includes overview", %{conn: conn} do
    conn = conn
    |> get(overview_path(conn, :index))
    assert html_response(conn, 200) =~ ~r/overview/i
  end
end

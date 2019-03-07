defmodule SqueezeWeb.PageControllerTest do
  use SqueezeWeb.ConnCase

  test "GET /privacy returns the privacy policy", %{conn: conn} do
    conn = conn
    |> get("/privacy")

    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  test "GET /terms returns the terms and conditions", %{conn: conn} do
    conn = conn
    |> get("/terms")

    assert html_response(conn, 200) =~ "Terms and Conditions"
  end
end

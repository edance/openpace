defmodule SqueezeWeb.StravaWebhookControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /webhook/strava" do
    test "returns 400 with no challenge", %{conn: conn} do
      conn = get(conn, "/webhook/strava")
      assert json_response(conn, 400) == %{}
    end

    test "returns 400 with bad challenge", %{conn: conn} do
      conn = get(conn, "/webhook/strava", %{"hub.verify_token" => "test"})
      assert json_response(conn, 400) == %{}
    end

    test "returns 200 with correct challenge", %{conn: conn} do
      challenge = "12345"
      params = %{"hub.challenge" => challenge, "hub.verify_token" => "STRAVA"}
      conn = get(conn, "/webhook/strava", params)
      assert json_response(conn, 200) == %{"hub.challenge" => challenge}
    end
  end

  describe "POST /webhook/strava" do
    test "returns 200 and empty response", %{conn: conn} do
      conn = post(conn, "/webhook/strava")
      assert json_response(conn, 200) == %{}
    end
  end
end

defmodule SqueezeWeb.GarminWebhookControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /webhook" do
    test "returns 200 and empty response", %{conn: conn} do
      conn = get(conn, "/webhook/garmin")
      assert json_response(conn, 200) == %{}
    end
  end

  describe "POST /webhook" do
    test "returns 200 and empty response", %{conn: conn} do
      conn = post(conn, "/webhook/garmin")
      assert json_response(conn, 200) == %{}
    end
  end
end

defmodule SqueezeWeb.FitbitWebhookControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /webhook" do
    test "verify with correct verify_token", %{conn: conn} do
      conn = conn
      |> get(fitbit_webhook_path(conn, :webhook), verify: "FITBIT")

      assert response(conn, 204) == ""
    end

    test "verify with incorrect verify_token", %{conn: conn} do
      conn = conn
      |> get(fitbit_webhook_path(conn, :webhook), verify: "1234")

      assert json_response(conn, 404) == %{}
    end
  end
end

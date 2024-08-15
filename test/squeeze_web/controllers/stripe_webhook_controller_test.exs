defmodule SqueezeWeb.StripeWebhookControllerTest do
  use SqueezeWeb.ConnCase

  describe "POST /webhook/stripe" do
    test "returns 400 without a raw body", %{conn: conn} do
      conn =
        conn
        |> put_req_header("stripe-signature", "abcd")
        |> post("/webhook/stripe")

      assert json_response(conn, 400) == %{}
    end

    test "returns 400 without a stripe signature", %{conn: conn} do
      conn =
        conn
        |> assign(:raw_body, "")
        |> post("/webhook/stripe")

      assert json_response(conn, 400) == %{}
    end

    # test "returns 200 and empty response", %{conn: conn} do
    #   conn = conn
    #   |> assign(:raw_body, "")
    # |> put_req_header("stripe-signature", "abcd")
    #   |> post("/webhook/stripe")
    #   assert json_response(conn, 200) == %{}
    # end
  end
end

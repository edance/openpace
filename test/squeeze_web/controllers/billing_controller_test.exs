defmodule SqueezeWeb.BillingControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /" do
    test "renders the title", %{conn: conn} do
      conn = conn
      |> get(billing_path(conn, :index))

      assert html_response(conn, 200) =~ ~r/billing overview/i
    end

    test "renders the user's payment method", %{conn: conn, user: user} do
      payment_method = insert(:payment_method, user: user)
      conn = conn
      |> get(billing_path(conn, :index))

      assert html_response(conn, 200) =~ payment_method.owner_name
    end
  end
end

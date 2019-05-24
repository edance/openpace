defmodule SqueezeWeb.BillingControllerTest do
  use SqueezeWeb.ConnCase

  import Mox

  describe "GET /" do
    test "renders the user's payment method", %{conn: conn, user: user} do
      payment_method = insert(:payment_method, user: user)
      conn = conn
      |> get(billing_path(conn, :index))

      assert html_response(conn, 200) =~ payment_method.last4
    end
  end

  describe "PUT /cancel" do
    setup [:setup_mocks]

    @tag :paid_user
    test "redirects and shows flash message", %{conn: conn} do
      conn = conn
      |> put(billing_path(conn, :cancel))

      assert get_flash(conn, :info) == "Your membership has been canceled"
      assert redirected_to(conn) == billing_path(conn, :index)
    end
  end

  defp setup_mocks(_) do
    Squeeze.MockPaymentProcessor
    |> expect(:cancel_subscription, fn(_) -> {:ok, %{}} end)

    {:ok, []}
  end
end

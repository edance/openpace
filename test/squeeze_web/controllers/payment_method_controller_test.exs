defmodule SqueezeWeb.PaymentMethodControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Billing

  describe "#new" do
    test "renders form", %{conn: conn} do
      conn = get conn, payment_method_path(conn, :new)
      assert html_response(conn, 200) =~ "New Payment Method"
    end
  end

  describe "#create" do
    test "redirects to billing#index when data is valid",
      %{conn: conn, user: user} do
      attrs = params_for(:payment_method)
      conn = conn
      |> post(payment_method_path(conn, :create), payment_method: attrs)

      assert redirected_to(conn) == billing_path(conn, :index)
      payment_methods = Billing.list_payment_methods(user)
      assert length(payment_methods) == 1
    end

    test "renders errors when data is invalid", %{conn: conn} do
      attrs = %{stripe_id: nil}
      conn = conn
      |> post(payment_method_path(conn, :create), payment_method: attrs)
      assert html_response(conn, 200) =~ "New Payment Method"
    end
  end

  describe "#delete" do
    setup [:create_payment_method]

    test "deletes user's payment_method",
      %{conn: conn, payment_method: payment_method, user: user} do
      conn = delete(conn, payment_method_path(conn, :delete, payment_method))
      assert redirected_to(conn) == billing_path(conn, :index)
      assert_raise Ecto.NoResultsError, fn ->
        Billing.get_payment_method!(user, payment_method.id) end
    end

    test "does not delete other user's payment_method", %{conn: conn} do
      payment_method = insert(:payment_method)
      assert_error_sent 404, fn ->
        delete(conn, payment_method_path(conn, :delete, payment_method))
      end
    end
  end

  def create_payment_method(%{user: user}) do
    {:ok, payment_method: insert(:payment_method, user: user)}
  end
end

defmodule SqueezeWeb.PaymentMethodControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Billing

  @create_attrs %{exp_month: 42, exp_year: 42, last4: "some last4", name: "some name", stripe_id: "some stripe_id"}
  @update_attrs %{exp_month: 43, exp_year: 43, last4: "some updated last4", name: "some updated name", stripe_id: "some updated stripe_id"}
  @invalid_attrs %{exp_month: nil, exp_year: nil, last4: nil, name: nil, stripe_id: nil}

  def fixture(:payment_method) do
    {:ok, payment_method} = Billing.create_payment_method(@create_attrs)
    payment_method
  end

  describe "index" do
    test "lists all payment_methods", %{conn: conn} do
      conn = get conn, payment_method_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Payment methods"
    end
  end

  describe "new payment_method" do
    test "renders form", %{conn: conn} do
      conn = get conn, payment_method_path(conn, :new)
      assert html_response(conn, 200) =~ "New Payment method"
    end
  end

  describe "create payment_method" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, payment_method_path(conn, :create), payment_method: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == payment_method_path(conn, :show, id)

      conn = get conn, payment_method_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Payment method"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, payment_method_path(conn, :create), payment_method: @invalid_attrs
      assert html_response(conn, 200) =~ "New Payment method"
    end
  end

  describe "edit payment_method" do
    setup [:create_payment_method]

    test "renders form for editing chosen payment_method", %{conn: conn, payment_method: payment_method} do
      conn = get conn, payment_method_path(conn, :edit, payment_method)
      assert html_response(conn, 200) =~ "Edit Payment method"
    end
  end

  describe "update payment_method" do
    setup [:create_payment_method]

    test "redirects when data is valid", %{conn: conn, payment_method: payment_method} do
      conn = put conn, payment_method_path(conn, :update, payment_method), payment_method: @update_attrs
      assert redirected_to(conn) == payment_method_path(conn, :show, payment_method)

      conn = get conn, payment_method_path(conn, :show, payment_method)
      assert html_response(conn, 200) =~ "some updated last4"
    end

    test "renders errors when data is invalid", %{conn: conn, payment_method: payment_method} do
      conn = put conn, payment_method_path(conn, :update, payment_method), payment_method: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Payment method"
    end
  end

  describe "delete payment_method" do
    setup [:create_payment_method]

    test "deletes chosen payment_method", %{conn: conn, payment_method: payment_method} do
      conn = delete conn, payment_method_path(conn, :delete, payment_method)
      assert redirected_to(conn) == payment_method_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, payment_method_path(conn, :show, payment_method)
      end
    end
  end

  defp create_payment_method(_) do
    payment_method = fixture(:payment_method)
    {:ok, payment_method: payment_method}
  end
end

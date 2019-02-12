defmodule SqueezeWeb.UserControllerTest do
  use SqueezeWeb.ConnCase

  import Mox

  alias Squeeze.Accounts

  describe "GET /sign-up" do
    @tag :guest_user
    test "as a guest user", %{conn: conn} do
      conn = conn
      |> get(user_path(conn, :new))

      assert html_response(conn, 200) =~ "Sign Up"
    end

    test "as a complete user", %{conn: conn} do
      conn = conn
      |> get(user_path(conn, :new))

      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end

  @tag :guest_user
  describe "PUT /sign-up" do
    setup [:setup_mocks]

    test "updates the users email and password", %{conn: conn, user: user} do
      register_user(conn)
      user = Accounts.get_user!(user.id)
      assert user.email == "test@example.com"
      refute is_nil(user.encrypted_password)
    end

    test "creates customer and subscription", %{conn: conn, user: user} do
      register_user(conn)
      user = Accounts.get_user!(user.id)
      refute is_nil(user.customer_id)
      refute is_nil(user.subscription_id)
    end
  end

  defp register_user(conn) do
    attrs = %{email: "test@example.com", encrypted_password: "password"}
    conn
    |> put(user_path(conn, :register), user: attrs)
  end

  defp setup_mocks(_) do
    customer = %{
      id: "customer_123456789"
    }
    subscription = %{
      id: "sub_123456789"
    }

    Squeeze.MockPaymentProcessor
    |> expect(:create_customer, fn(_) -> {:ok, customer} end)

    Squeeze.MockPaymentProcessor
    |> expect(:create_subscription, fn(_, _, _) -> {:ok, subscription} end)

    {:ok, []}
  end
end

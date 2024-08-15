defmodule SqueezeWeb.UserControllerTest do
  use SqueezeWeb.ConnCase

  import Mox

  alias Squeeze.Accounts

  describe "GET /sign-up" do
    @tag :no_user
    test "as a visitor", %{conn: conn} do
      conn =
        conn
        |> get(user_path(conn, :new))

      assert html_response(conn, 200) =~ "Sign Up"
    end

    test "as a complete user", %{conn: conn} do
      conn =
        conn
        |> get(user_path(conn, :new))

      assert redirected_to(conn) == "/dashboard/overview"
    end
  end

  describe "POST /sign-up" do
    setup [:setup_mocks]

    @tag :no_user
    test "creates a user", %{conn: conn} do
      conn = create_user(conn)
      user = Accounts.get_user_by_email("test@example.com")
      assert user.email == "test@example.com"
      refute is_nil(user.encrypted_password)
      assert html_response(conn, 302)
    end

    @tag :no_user
    test "with invalid params responds 422", %{conn: conn} do
      attrs = %{email: "test", encrypted_password: "password"}

      conn =
        conn
        |> post(user_path(conn, :register), user: attrs)

      assert html_response(conn, 422) =~ "Sign Up"
    end
  end

  defp create_user(conn) do
    attrs = %{
      email: "test@example.com",
      encrypted_password: "password",
      first_name: "Test",
      last_name: "Testerson"
    }

    conn
    |> post(user_path(conn, :register), user: attrs)
  end

  defp setup_mocks(_) do
    customer = %{
      id: "customer_123456789"
    }

    Squeeze.MockPaymentProcessor
    |> expect(:create_customer, fn _ -> {:ok, customer} end)

    {:ok, []}
  end
end

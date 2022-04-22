defmodule SqueezeWeb.ForgotPasswordControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /show" do
    @tag :no_user
    test "renders form", %{conn: conn} do
      conn = conn
      |> get(forgot_password_path(conn, :show))

      assert html_response(conn, 200) =~ ~r/forgot your password/i
      assert html_response(conn, 200) =~ ~r/input/i
      assert html_response(conn, 200) =~ ~r/reset password/i
    end
  end

  describe "POST /forgot-password" do
    @tag :no_user
    test "sends an email and redirects to home", %{conn: conn} do
      user = insert(:user)
      conn = conn
      |> post(forgot_password_path(conn, :request), %{email: user.email})

      assert redirected_to(conn) == home_path(conn, :index)
    end

    @tag :no_user
    test "with invalid email shows alert", %{conn: conn} do
      conn = conn
      |> post(forgot_password_path(conn, :request), email: "madeup@email.com")

      assert html_response(conn, 200) =~ "Email not found in our systems"
    end
  end
end

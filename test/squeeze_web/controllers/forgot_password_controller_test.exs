defmodule SqueezeWeb.ForgotPasswordControllerTest do
  use SqueezeWeb.ConnCase

  describe "GET /show" do
    test "renders form", %{conn: conn} do
      conn = conn
      |> get(forgot_password_path(conn, :show))

      assert html_response(conn, 200) =~ ~r/forgot your password/i
      assert html_response(conn, 200) =~ ~r/input/i
      assert html_response(conn, 200) =~ ~r/reset password/i
    end
  end

  describe "POST /forgot-password" do
    test "sends an email and redirects to home", %{conn: conn, user: user} do
      conn = conn
      |> post(forgot_password_path(conn, :request), %{email: user.email})

      assert redirected_to(conn) == page_path(conn, :index)
    end
  end
end

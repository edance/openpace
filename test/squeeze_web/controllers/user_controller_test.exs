defmodule SqueezeWeb.UserControllerTest do
  use SqueezeWeb.ConnCase

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
  test "PUT /sign-up", %{conn: conn, user: user} do
    attrs = %{email: "test@example.com", encrypted_password: "abc"}
    conn
    |> put(user_path(conn, :register), user: attrs)

    assert Accounts.get_user!(user.id).email == "test@example.com"
  end
end

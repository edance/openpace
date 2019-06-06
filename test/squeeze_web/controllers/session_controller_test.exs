defmodule SqueezeWeb.SessionControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Guardian.Plug

  test "renders login page", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/Welcome/
  end

  describe "POST create" do
    test "with a user with no password", %{conn: conn} do
      user = insert(:user, encrypted_password: nil)
      session_params = %{email: user.email, password: "password"}
      conn = conn
      |> post(session_path(conn, :create), session: session_params)

      assert html_response(conn, 200) =~ ~r/invalid password/i
      refute conn.assigns.current_user.id == user.id
    end

    test "with a user and valid password", %{conn: conn} do
      encrypted_password = Argon2.hash_pwd_salt("password")
      user = insert(:user, encrypted_password: encrypted_password)
      session_params = %{email: user.email, password: "password"}
      conn = conn
      |> post(session_path(conn, :create), session: session_params)

      assert redirected_to(conn) == dashboard_path(conn, :index)
    end

    test "with a user and invalid password", %{conn: conn} do
      encrypted_password = Argon2.hash_pwd_salt("password")
      user = insert(:user, encrypted_password: encrypted_password)
      session_params = %{email: user.email, password: "abc"}
      conn = conn
      |> post(session_path(conn, :create), session: session_params)

      assert html_response(conn, 200) =~ ~r/invalid password/i
      refute conn.assigns.current_user.id == user.id
    end

    test "with an invalid email address", %{conn: conn} do
      session_params = %{email: "test@email.com", password: "password"}
      conn = conn
      |> post(session_path(conn, :create), session: session_params)

      assert html_response(conn, 200) =~ ~r/invalid email/i
    end
  end

  test "logs out user on delete", %{conn: conn} do
    conn = delete conn, session_path(conn, :delete)
    user = Plug.current_resource(conn)
    assert user == nil
  end
end

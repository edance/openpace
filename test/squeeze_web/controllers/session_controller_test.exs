defmodule SqueezeWeb.SessionControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Guardian.Plug

  @tag :no_user
  test "renders login page", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/Welcome/
  end

  describe "POST create" do
    @tag :no_user
    test "with a user and valid password", %{conn: conn} do
      encrypted_password = Argon2.hash_pwd_salt("password")
      user = insert(:user, encrypted_password: encrypted_password)
      session_params = %{email: user.email, password: "password"}

      conn =
        conn
        |> post(session_path(conn, :create), session: session_params)

      assert redirected_to(conn) == overview_path(conn, :index)
    end

    @tag :no_user
    test "with a user and invalid password", %{conn: conn} do
      encrypted_password = Argon2.hash_pwd_salt("password")
      user = insert(:user, encrypted_password: encrypted_password)
      session_params = %{email: user.email, password: "abc"}

      conn =
        conn
        |> post(session_path(conn, :create), session: session_params)

      assert html_response(conn, 422) =~ ~r/invalid password/i
    end

    @tag :no_user
    test "with an invalid email address", %{conn: conn} do
      session_params = %{email: "test@email.com", password: "password"}

      conn =
        conn
        |> post(session_path(conn, :create), session: session_params)

      assert html_response(conn, 422) =~ ~r/invalid email/i
    end
  end

  test "logs out user on delete", %{conn: conn} do
    conn = delete(conn, session_path(conn, :delete))
    user = Plug.current_resource(conn)
    assert user == nil
  end
end

defmodule SqueezeWeb.Api.UserControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Accounts

  @tag :no_user
  describe "#create" do
    test "returns an auth token and the user", %{conn: conn} do
      attrs = %{
        email: "test@example.com",
        encrypted_password: "password",
        first_name: "Test",
        last_name: "Testerson"
      }

      conn = conn |> post(api_user_path(conn, :create), attrs)

      assert response = json_response(conn, 201)
      assert Map.keys(response) |> Enum.member?("token")
      assert Map.keys(response) |> Enum.member?("user")
    end

    test "with invalid params", %{conn: conn} do
      attrs = %{
        email: "test@example.com",
        encrypted_password: "password",
      }

      conn = conn |> post(api_user_path(conn, :create), attrs)

      assert json_response(conn, 422)
    end
  end

  @tag :no_user
  describe "#sign_in" do
    test "with a valid password", %{conn: conn} do
      user = insert(:user)
      attrs = %{
        email: user.email,
        password: "password"
      }
      conn = conn |> post(api_user_path(conn, :signin), attrs)

      assert response = json_response(conn, 201)
      assert Map.keys(response) |> Enum.member?("token")
      assert Map.keys(response) |> Enum.member?("user")
    end

    test "with an invalid password", %{conn: conn} do
      user = insert(:user)
      attrs = %{
        email: user.email,
        password: "badpassword"
      }
      conn = conn |> post(api_user_path(conn, :signin), attrs)

      assert json_response(conn, 401)
    end
  end

  describe "#update" do
    test "with valid data saves user", %{conn: conn} do
      user = conn.assigns.current_user
      conn = put(conn, api_user_path(conn, :update), user: %{first_name: "ABC"})
      assert Accounts.get_user!(user.id).first_name == "ABC"
      assert response(conn, 204) == ""
    end

    test "with invalid data renders errors", %{conn: conn} do
      conn = put(conn, api_user_path(conn, :update), user: %{email: "ABC"})
      assert json_response(conn, 422)
    end
  end

  describe "#me" do
    test "returns the current user", %{conn: conn} do
      conn = get(conn, api_user_path(conn, :me))

      assert response = json_response(conn, 200)
    end
  end
end

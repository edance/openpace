defmodule SqueezeWeb.ProfileControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Accounts

  test "#edit includes profile", %{conn: conn} do
    conn = conn
    |> get(profile_path(conn, :edit))
    assert html_response(conn, 200) =~ ~r/profile/i
  end

  describe "#update" do
    test "with valid data saves user and redirects to dashboard", %{conn: conn} do
      user = conn.assigns.current_user
      conn = put(conn, profile_path(conn, :update), user: %{first_name: "ABC"})
      assert Accounts.get_user!(user.id).first_name == "ABC"
      assert redirected_to(conn) == dashboard_path(conn, :index)
    end

    test "with invalid data renders errors", %{conn: conn} do
      conn = put(conn, profile_path(conn, :update), user: %{email: "ABC"})
      assert html_response(conn, 200) =~ ~r/profile/i
    end
  end
end

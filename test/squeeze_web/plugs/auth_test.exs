defmodule SqueezeWeb.Plug.AuthTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Guardian.Plug
  alias SqueezeWeb.Plug.Auth

  test "gets authenticated user from session", %{conn: conn} do
    conn = conn
    |> call_auth_plug()

    assert assigned_current_user?(conn)
  end

  @tag :no_user
  test "gets authenticated user from Guardian", %{conn: conn} do
    user = insert(:user)

    conn = conn
    |> Plug.sign_in(user)
    |> call_auth_plug()

    assert assigned_current_user?(conn)
  end

  @tag :no_user
  test "creates a guest user if none exists", %{conn: conn} do
    conn = conn
    |> call_auth_plug()

    assert assigned_current_user?(conn)
  end

  defp assigned_current_user?(conn) do
    assert conn.assigns[:current_user] != nil
  end

  defp call_auth_plug(conn) do
    Auth.call(conn, %{})
  end
end

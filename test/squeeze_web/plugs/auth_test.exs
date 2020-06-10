defmodule SqueezeWeb.Plug.AuthTest do
  use SqueezeWeb.ConnCase

  alias SqueezeWeb.Plug.Auth

  test "gets authenticated user from session", %{conn: conn} do
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

defmodule SqueezeWeb.ResetPasswordControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.PasswordLinkGenerator

  describe "GET /show" do
    test "with valid token and signature", %{conn: conn, user: user} do
      link = user
      |> PasswordLinkGenerator.create_link()
      conn = conn
      |> get(link)

      assert html_response(conn, 200) =~ "Please reset your password below"
    end

    test "with an expired token", %{conn: conn, user: user} do
      time = :erlang.system_time(:seconds) - 86_401 # One day and one second
      link = user
      |> PasswordLinkGenerator.create_link(time)
      conn = conn
      |> get(link)

      assert get_flash(conn, :error) == "Token has expired"
      assert redirected_to(conn) == page_path(conn, :index)
    end

    test "with an invalid token", %{conn: conn, user: user} do
      token = "MTU1MTMyNDk2Nyw2MjY1Ng=="
      link = user |> PasswordLinkGenerator.create_link()
      %{query: query, path: path} = URI.parse(link)
      query = query
      |> URI.query_decoder()
      |> Map.new()
      |> Map.put("token", token)
      |> URI.encode_query()

      conn = conn
      |> get("#{path}?#{query}")

      assert get_flash(conn, :error) == "Token not valid"
      assert redirected_to(conn) == page_path(conn, :index)
    end
  end
end

defmodule SqueezeWeb.ResetPasswordControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Accounts
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
      conn = conn
      |> get(expired_link(user))

      assert get_flash(conn, :error) == "Token has expired"
      assert redirected_to(conn) == page_path(conn, :index)
    end

    test "with an invalid token", %{conn: conn, user: user} do
      conn = conn
      |> get(invalid_link(user))

      assert get_flash(conn, :error) == "Token not valid"
      assert redirected_to(conn) == page_path(conn, :index)
    end
  end

  describe "POST /reset" do
    test "with valid token and signature", %{conn: conn, user: user} do
      attrs = %{encrypted_password: "password1234"}
      link = PasswordLinkGenerator.create_link(user)
      conn = post(conn, link, user: attrs)

      assert get_flash(conn, :info) == "Password was reset"
      assert redirected_to(conn) == session_path(conn, :new)
      refute user.encrypted_password ==
        Accounts.get_user!(user.id).encrypted_password
    end

    test "with an invalid password", %{conn: conn, user: user} do
      attrs = %{encrypted_password: "abc"}
      link = PasswordLinkGenerator.create_link(user)
      conn = post(conn, link, user: attrs)

      assert html_response(conn, 200) =~ "Please reset your password below"
    end

    test "with invalid token", %{conn: conn, user: user} do
      attrs = %{encrypted_password: "password1234"}
      link = invalid_link(user)
      conn = post(conn, link, user: attrs)
      assert get_flash(conn, :error) == "Token not valid"
      assert redirected_to(conn) == page_path(conn, :index)
    end
  end

  defp expired_link(user) do
    time = :erlang.system_time(:seconds) - 86_401 # One day and one second
    PasswordLinkGenerator.create_link(user, time)
  end

  defp invalid_link(user) do
    link = PasswordLinkGenerator.create_link(user)
    time = :erlang.system_time(:seconds) - 5
    %{query: query, path: path} = URI.parse(link)
    query = query
    |> URI.query_decoder()
    |> Map.new()
    |> Map.put("token", create_token(user, time))
    |> URI.encode_query()
    "#{path}?#{query}"
  end

  defp create_token(user, time) do
    Base.url_encode64("#{time},#{user.id}")
  end
end

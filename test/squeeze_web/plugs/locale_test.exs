defmodule SqueezeWeb.Plug.LocaleTest do
  use SqueezeWeb.ConnCase

  alias SqueezeWeb.Plug.Locale

  test "sets the locale from params", %{conn: conn} do
    conn = conn
    |> setup_conn()
    |> add_locale_param("en")
    |> call_locale_plug()

    assert Gettext.get_locale(SqueezeWeb.Gettext) == "en"
    assert persisted_locale?(conn)
  end

  test "sets the locale from cookie", %{conn: conn} do
    conn = conn
    |> setup_conn()
    |> add_locale_cookie("en")
    |> call_locale_plug()

    assert Gettext.get_locale(SqueezeWeb.Gettext) == "en"
    assert persisted_locale?(conn)
  end

  test "sets the locale from headers", %{conn: conn} do
    conn = conn
    |> setup_conn()
    |> add_locale_header("en")
    |> call_locale_plug()

    assert Gettext.get_locale(SqueezeWeb.Gettext) == "en"
    assert persisted_locale?(conn)
  end

  defp setup_conn(conn) do
    conn
    |> fetch_query_params()
    |> fetch_cookies()
  end

  defp add_locale_param(conn, locale) do
    %{conn | params: Map.put(conn.params, "locale", locale)}
  end

  defp add_locale_cookie(conn, locale) do
    %{conn | cookies: Map.put(conn.cookies, "locale", locale)}
  end

  defp add_locale_header(conn, locale) do
    put_req_header(conn, "accept-language", locale)
  end

  defp call_locale_plug(conn) do
    Locale.call(conn, %{})
  end

  def persisted_locale?(conn) do
    conn.cookies["locale"] != nil
  end
end

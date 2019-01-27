defmodule SqueezeWeb.Plug.Locale do
  import Plug.Conn

  @moduledoc """
  This plug sets the locale for Gettext using:

  1. locale query param
  2. locale cookie
  3. or accept-language header
  """

  @locales Gettext.known_locales(SqueezeWeb.Gettext)

  alias SetLocale.Headers

  def init(_), do: nil

  def call(conn, _opts) do
    case locale_from_params(conn) || locale_from_cookies(conn) || locale_from_header(conn) do
      nil     -> conn
      locale  ->
        Gettext.put_locale(SqueezeWeb.Gettext, locale)
        conn
        |> persist_locale(locale)
    end
  end

  defp persist_locale(conn, new_locale) do
    if conn.cookies["locale"] != new_locale do
      conn |> put_resp_cookie("locale", new_locale)
    else
      conn
    end
  end

  defp locale_from_params(conn), do: conn.params["locale"] |> validate_locale

  defp locale_from_cookies(conn), do: conn.cookies["locale"] |> validate_locale

  defp validate_locale(locale) when locale in @locales, do: locale
  defp validate_locale(_locale), do: nil

  defp locale_from_header(conn) do
    conn
    |> Headers.extract_accept_language()
    |> Enum.find(nil, fn accepted_locale -> Enum.member?(@locales, accepted_locale) end)
  end
end

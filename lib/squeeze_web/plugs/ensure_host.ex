defmodule SqueezeWeb.Plug.EnsureHost do
  @moduledoc """
  Forces www at the beginning of the url.
  """

  alias Phoenix.Controller

  @host_url System.get_env("HOST_URL")

  def init(_), do: nil

  def call(%{host: host, method: "GET"} = conn, _opts) do
    if URI.parse(@host_url).host == host do
      conn
    else
      conn
      |> Controller.redirect(external: build_url(conn))
    end
  end

  def call(conn, _opts), do: conn

  defp build_url(conn)  do
    %{scheme: scheme, host: host, port: port} = URI.parse(@host_url)
    "#{scheme}://#{host}:#{port}#{conn.request_path}"
  end
end

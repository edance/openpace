defmodule SqueezeWeb.Plug.EnsureHost do
  @moduledoc """
  Forces www at the beginning of the url.
  """

  alias Phoenix.Controller
  alias Plug.Conn

  @config Application.get_env(:squeeze, SqueezeWeb.Endpoint)

  def init(_), do: nil

  def call(%{host: host, method: "GET"} = conn, _opts) do
    if @config[:url][:host] == host do
      conn
    else
      conn
      |> Controller.redirect(external: build_url(conn))
      |> Conn.halt()
    end
  end

  def call(conn, _opts), do: conn

  defp build_url(%{request_path: path})  do
    url = @config[:url]
    %URI{
      scheme: url[:scheme],
      host: url[:host],
      port: url[:port],
      path: path
    }
    |> URI.to_string()
  end
end

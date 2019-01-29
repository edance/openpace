# https://hexdocs.pm/plug/Plug.Parsers.html#module-custom-body-reader
defmodule CacheBodyReader do
  @moduledoc """
  Cache the body to perform verification later, such as HTTP Signature Verification.
  """

  alias Plug.Conn

  def read_body(conn, opts) do
    {:ok, body, conn} = Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
    {:ok, body, conn}
  end
end

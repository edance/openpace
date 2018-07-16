defmodule SqueezeWeb.Plug.Auth do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _) do
    cond do
      user = conn.assigns[:current_user] ->
        assign(conn, :current_user, user)
      user = Squeeze.Guardian.Plug.current_resource(conn) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end
end

defmodule SqueezeWeb.Plug.Auth do
  import Plug.Conn

  @moduledoc """
  This module defines the auth plug pulls the user from the current session.
  """

  alias Squeeze.Guardian

  def init(_), do: nil

  def call(conn, _) do
    cond do
      user = conn.assigns[:current_user] ->
        assign(conn, :current_user, user)
      user = Guardian.Plug.current_resource(conn) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end
end

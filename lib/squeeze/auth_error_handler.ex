defmodule Squeeze.AuthErrorHandler do
  @moduledoc """
  This module handles redirection if the user is not authenticated.
  """

  import Plug.Conn

  alias Phoenix.Controller

  def auth_error(conn, _, _opts) do
    conn
    |> clear_session()
    |> Controller.redirect(to: "/")
    |> halt()
  end
end

defmodule Squeeze.AuthErrorHandler do
  @moduledoc """
  This module handles redirection if the user is not authenticated.
  """

  import Plug.Conn

  alias Phoenix.Controller
  alias SqueezeWeb.Router.Helpers, as: Routes

  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    conn
    |> clear_session()
    |> Controller.put_flash(:error, "You must be logged in to view")
    |> Controller.redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
  def auth_error(conn, {:already_authenticated, _reason}, _opts) do
    conn
    |> Controller.redirect(to: Routes.overview_path(conn, :index))
    |> halt()
  end
  def auth_error(conn, _error, _opts) do
    conn
    |> clear_session()
    |> Controller.put_flash(:error, "You must be logged in to view")
    |> Controller.redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
end

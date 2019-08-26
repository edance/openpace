defmodule SqueezeWeb.Plug.RequireRegistered do
  import Plug.Conn

  @moduledoc """
  This modules requires either:

  1. The user has registered
  2. The page has a query param of welcome

  After onboarding, the user will see their dashboard and be prompted to register.
  """

  alias Phoenix.Controller

  def init(_), do: nil

  def call(conn, _x) do
    user = conn.assigns.current_user

    if user.registered || !is_nil(conn.query_params["welcome"]) do
      conn
    else
      conn
      |> Controller.redirect(to: "/")
      |> halt()
    end
  end
end

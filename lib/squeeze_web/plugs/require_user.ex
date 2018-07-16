defmodule SqueezeWeb.Plug.RequireUser do
  import Plug.Conn
  import Phoenix.Controller

  alias SqueezeWeb.Router.Helpers

  def init(options) do
    options
  end


  def call(conn, _) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must sign in first.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end

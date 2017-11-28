defmodule Squeeze.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, _, _opts) do
    conn
    |> Phoenix.Controller.put_flash(:error, "Login required")
    |> Phoenix.Controller.redirect(to: "/")
    |> halt()
  end
end

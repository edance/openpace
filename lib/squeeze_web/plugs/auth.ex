defmodule SqueezeWeb.Plug.Auth do
  import Plug.Conn

  alias Squeeze.{Accounts, Guardian}

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
        {:ok, user} = Accounts.create_guest_user()
        conn
        |> Guardian.Plug.sign_in(user)
        |> assign(:current_user, user)
    end
  end
end

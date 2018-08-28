defmodule SqueezeWeb.Plug.Auth do
  import Plug.Conn

  @moduledoc """
  This module defines the auth plug which does one of two things:

  1. Pulls the user from the current session
  2. Creates a new guest user

  All visitors are a user which allows us to collect user preferences
  before they actually sign up.
  """

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

defmodule SqueezeWeb.Plug.VerifyRememberMe do
  @moduledoc """
  Use this plug to load a remember me cookie and convert it into an access token

  ## Example

      plug SqueezeWeb.Plug.VerifyRememberMe

  This should be run after Guardian.Plug.VerifySession

  It assumes that there is a cookie called 'remember_me' and that it has a
  refresh type token
  """

  alias Squeeze.Guardian
  alias SqueezeWeb.Plug.Auth

  @doc false
  def init(opts \\ %{}), do: Enum.into(opts, %{})

  @doc false
  def call(conn, _opts) do
    if Guardian.Plug.authenticated?(conn) do
      conn
    else
      token = conn.req_cookies["guardian_default_token"]
      case Guardian.resource_from_token(token) do
        {:ok, user, _claims} -> Auth.sign_in(conn, user)
        _error -> conn
      end
    end
  end
end

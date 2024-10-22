defmodule SqueezeWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Phoenix.ConnTest
  alias Plug.Conn
  alias Squeeze.{Factory, Guardian, Repo}
  alias SqueezeWeb.Plug.Auth

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import SqueezeWeb.Router.Helpers
      import Squeeze.Factory
      import Plug.HTML, only: [html_escape: 1]

      alias SqueezeWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint SqueezeWeb.Endpoint

      use SqueezeWeb, :verified_routes
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    user = create_user(tags)

    conn =
      ConnTest.build_conn()
      |> sign_in_user(user)
      |> put_auth_header(user)
      |> put_session_token(user)

    {:ok, conn: conn, user: user}
  end

  def sign_in_user(conn, nil), do: conn
  def sign_in_user(conn, user), do: Auth.sign_in(conn, user)

  defp put_auth_header(conn, nil), do: conn

  defp put_auth_header(conn, user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    conn
    |> Conn.put_req_header("authorization", "Bearer #{token}")
  end

  defp put_session_token(conn, nil), do: conn

  defp put_session_token(conn, user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Conn.put_session(:guardian_default_token, token)
  end

  defp create_user(%{no_user: true}), do: nil
  defp create_user(%{paid_user: true}), do: Factory.insert(:paid_user)
  defp create_user(_), do: Factory.insert(:user)
end

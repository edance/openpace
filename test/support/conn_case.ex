defmodule SqueezeWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Phoenix.ConnTest
  alias Plug.Conn
  alias Squeeze.{Factory, Repo}

  using do
    quote do
      # Import conveniences for testing with connections
      use ConnTest
      import SqueezeWeb.Router.Helpers
      import Squeeze.Factory

      # The default endpoint for testing
      @endpoint SqueezeWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    user = Factory.insert(:user)

    conn =
      ConnTest.build_conn()
      |> Conn.assign(:current_user, user)

    {:ok, conn: conn, user: user}
  end
end

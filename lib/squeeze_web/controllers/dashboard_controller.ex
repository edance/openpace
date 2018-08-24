defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Sync

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

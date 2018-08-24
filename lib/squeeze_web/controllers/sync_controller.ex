defmodule SqueezeWeb.SyncController do
  use SqueezeWeb, :controller

  alias Squeeze.Sync

  def sync(conn, _params) do
    Sync.load_activities(conn.assigns.current_user)
    conn
    |> redirect(to: dashboard_path(conn, :index))
  end
end

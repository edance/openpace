defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Sync

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    Task.start(fn -> Sync.load_activities(current_user) end)
    redirect(conn, to: overview_path(conn, :index))
  end
end

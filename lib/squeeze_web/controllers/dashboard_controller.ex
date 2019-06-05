defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.overview_path(conn, :index))
  end
end

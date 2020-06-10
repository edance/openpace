defmodule SqueezeWeb.HomeController do
  use SqueezeWeb, :controller

  plug :redirect_registered_user

  def index(conn, _params) do
    render(conn, "index.html")
  end

  defp redirect_registered_user(conn, _) do
    case conn.assigns.current_user do
      nil -> conn
      _ ->
        conn
        |> redirect(to: Routes.dashboard_path(conn, :index))
        |> halt()
    end
  end
end

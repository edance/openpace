defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias SqueezeWeb.Endpoint
  alias Squeeze.Strava.HistoryLoader

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    Task.start(fn -> load_history(current_user) end)
    render(conn, "index.html")
  end

  defp load_history(user) do
    HistoryLoader.load_recent(user)
    Endpoint.broadcast("notification:#{user.id}", "history_loaded", %{})
  end
end

defmodule FitbitWeb.PageController do
  use FitbitWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

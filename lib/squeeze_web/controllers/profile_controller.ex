defmodule SqueezeWeb.ProfileController  do
  use SqueezeWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end

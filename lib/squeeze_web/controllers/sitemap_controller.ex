defmodule SqueezeWeb.SitemapController do
  use SqueezeWeb, :controller
  @moduledoc false

  def index(conn, _params) do
    render(conn, "index.xml")
  end
end

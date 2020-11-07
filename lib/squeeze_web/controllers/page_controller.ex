defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller

  def privacy_policy(conn, _params) do
    render(conn, "privacy_policy.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end
end

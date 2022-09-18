defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller
  @moduledoc false

  def privacy_policy(conn, _params) do
    render(conn, "privacy_policy.html", page_title: "Privacy Policy")
  end

  def support(conn, _params) do
    render(conn, "support.html", page_title: "Support")
  end

  def terms(conn, _params) do
    render(conn, "terms.html", page_title: "Terms and Conditions")
  end
end

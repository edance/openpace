defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  def index(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user_prefs(user.user_prefs)

    if user.registered do
      redirect(conn, to: dashboard_path(conn, :index))
    else
      render(conn, "index.html", changeset: changeset, step: "distance")
    end
  end

  def privacy_policy(conn, _params) do
    render(conn, "privacy_policy.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end
end

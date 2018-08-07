defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  def index(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user_prefs(user.user_prefs)
    render(conn, "index.html", changeset: changeset, step: "distance")
  end
end

defmodule SqueezeWeb.PageController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User

  def index(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user_prefs(user.user_prefs)
    case User.onboarded?(user) do
      true -> redirect(conn, to: dashboard_path(conn, :index))
      false -> render(conn, "index.html", changeset: changeset, step: "distance")
    end
  end
end

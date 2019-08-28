defmodule SqueezeWeb.OnboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  def index(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user_prefs(user.user_prefs)
    render(conn, "index.html", changeset: changeset)
  end

  def update(conn, %{"user_prefs" => pref_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_prefs(user.user_prefs, pref_params) do
      {:ok, _} ->
        conn
        |> redirect(to: Routes.overview_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", changeset: changeset)
    end
  end
end

defmodule SqueezeWeb.ProfileController  do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def edit(conn, _params, current_user) do
    credentials = Accounts.list_credentials(current_user)
    changeset = Accounts.change_user(current_user)
    render(conn, "edit.html", changeset: changeset, credentials: credentials)
  end

  def update(conn, %{"user" => user_params}, current_user) do
    case Accounts.update_user(current_user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Your preferences have been updated"))
        |> redirect(to: dashboard_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        credentials = Accounts.list_credentials(current_user)
        render(conn, "edit.html", changeset: changeset, credentials: credentials)
    end
  end
end

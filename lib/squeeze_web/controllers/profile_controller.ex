defmodule SqueezeWeb.ProfileController  do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def edit(conn, _params, current_user) do
    changeset = Accounts.change_user(current_user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}, current_user) do
    case Accounts.update_user(current_user, user_params) do
      {:ok, _} ->
        conn
        |> redirect(to: dashboard_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end
end

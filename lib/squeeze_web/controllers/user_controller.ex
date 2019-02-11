defmodule SqueezeWeb.UserController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Billing

  def new(conn, %{}) do
    user = conn.assigns.current_user
    if User.onboarded?(user) do
      redirect(conn, to: dashboard_path(conn, :index))
    else
      changeset = Accounts.change_user(user)
      render(conn, "new.html", changeset: changeset)
    end
  end

  def register(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    case Accounts.register_user(user, user_params) do
      {:ok, _user} ->
        Billing.start_free_trial(user)
        conn
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: dashboard_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end

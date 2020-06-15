defmodule SqueezeWeb.UserController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Billing
  alias Squeeze.{Email, Mailer}

  def new(conn, %{}) do
    case conn.assigns[:current_user] do
      nil ->
        changeset = Accounts.change_user(%User{})
        render(conn, "new.html", changeset: changeset)
      _ -> redirect(conn, to: Routes.dashboard_path(conn, :index))
    end
  end

  def register(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    with {:ok, user} <- Accounts.register_user(user, user_params),
         {:ok, user} <- Billing.start_free_trial(user) do
      send_welcome_email(user)
      render_success(conn)
    else
      {:error, changeset} -> render_error(conn, changeset)
    end
  end

  defp render_success(conn) do
    conn
    |> put_flash(:info, "Signed up successfully.")
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  defp render_error(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render("new.html", changeset: changeset)
  end

  defp send_welcome_email(user) do
    user
    |> Email.welcome_email()
    |> Mailer.deliver_later()
  end
end

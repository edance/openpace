defmodule SqueezeWeb.UserController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.{Email, Mailer}
  alias Squeeze.Reporter
  alias SqueezeWeb.Plug.Auth

  require Logger

  @honeypot_field "website"

  plug :validate_honeypot when action in [:register]
  plug :validate_timestamp when action in [:register]

  def new(conn, %{}) do
    case conn.assigns[:current_user] do
      nil ->
        changeset = Accounts.change_user(%User{})

        conn
        |> put_session(:registration_timestamp, Timex.now())
        |> render("new.html", changeset: changeset)

      _ ->
        redirect(conn, to: Routes.dashboard_path(conn, :index))
    end
  end

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        Reporter.report_new_user(user)

        conn
        |> Auth.sign_in(user)
        |> send_welcome_email(user)
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, changeset} ->
        render_error(conn, changeset)
    end
  end

  defp validate_honeypot(conn, _) do
    value = conn.params["user"][@honeypot_field]

    if is_nil(value) || String.trim(value) == "" do
      conn
    else
      Logger.warn("Spam user: Honeypot field")
      changeset = Accounts.change_user(%User{})

      conn
      |> put_flash(:error, "Sorry we can't process your request. Error code: 005")
      |> render_error(changeset)
      |> halt()
    end
  end

  defp validate_timestamp(conn, _) do
    timestamp = get_session(conn, :registration_timestamp)
    diff = Timex.diff(Timex.now(), timestamp, :seconds)

    if diff >= 4 do
      conn
    else
      Logger.warn("Spam user: Timestamp validation")
      changeset = Accounts.change_user(%User{})

      conn
      |> put_flash(:error, "Sorry we can't process your request. Error code: 006")
      |> render_error(changeset)
      |> halt()
    end
  end

  defp render_error(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render("new.html", changeset: changeset)
  end

  defp send_welcome_email(conn, user) do
    user
    |> Email.welcome_email()
    |> Mailer.deliver_later()

    conn
  end
end

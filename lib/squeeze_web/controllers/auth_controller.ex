defmodule SqueezeWeb.AuthController do
  use SqueezeWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Squeeze.Accounts

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    credentials = %{provider: "fitbit", token: auth.credentials.token, uid: auth.uid}
    user_params = Map.merge(Map.from_struct(auth.info), %{credential: credentials})
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: "/")
      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:info, "Didn't Work")
        |> redirect(to: "/")
    end
  end
end

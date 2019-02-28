defmodule SqueezeWeb.ResetPasswordController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.PasswordLinkGenerator

  plug :validate_token

  def show(conn, %{"token" => token, "signature" => signature}) do
    changeset = Accounts.change_user(%User{})
    render(conn, "show.html", changeset: changeset,
      signature: signature, token: token)
  end

  def reset(conn, %{"token" => token, "signature" => signature, "user" => params}) do
    [_, user_id] = PasswordLinkGenerator.parse_token(token)
    user = Accounts.get_user!(user_id)
    case Accounts.update_user_password(user, params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password was reset")
        |> redirect(to: session_path(conn, :new))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", changeset: changeset,
          signature: signature, token: token, user: user)
    end
  end

  defp validate_token(conn, _) do
    token = conn.params["token"]
    signature = conn.params["signature"]
    case PasswordLinkGenerator.verify_link(token, signature) do
      {:ok, _} -> conn
      {:error, error_msg} ->
        conn
        |> put_flash(:error, error_msg)
        |> redirect(to: page_path(conn, :index))
    end
  end
end

defmodule SqueezeWeb.ResetPasswordController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Crypto

  @token_ttl 86_400

  plug :validate_token

  def show(conn, %{"token" => token, "signature" => signature}) do
    [_, user_id] = parse_token(token)
    user = Accounts.get_user!(user_id)
    changeset = Accounts.change_user(%User{})
    render(conn, "show.html", changeset: changeset,
      signature: signature, token: token, user: user)
  end

  def reset(conn, %{"token" => token, "signature" => signature, "user" => params}) do
    [_, user_id] = parse_token(token)
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
    case check_token(token, signature) do
      {:ok, _} -> conn
      {:error, error_msg} ->
        conn
        |> put_flash(:error, error_msg)
        |> redirect(to: page_path(conn, :index))
    end
  end

  defp check_token(token, signature) do
    [timestamp, _] = parse_token(token)
    diff = :erlang.system_time(:seconds) - timestamp
    if diff > @token_ttl do
      {:error, "Token has expired"}
    else
      Crypto.verify(token, signature)
    end
  end

  defp parse_token(token) do
    token
    |> Base.url_decode64!()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end

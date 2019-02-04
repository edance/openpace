defmodule SqueezeWeb.UserController  do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts

  def register(conn, %{"user" => user_params}) do
    require IEx; IEx.pry
    user = conn.assigns.current_user
    case Accounts.update_user(user, user_params) do
      {:ok, _} ->
        render(conn, "success.json")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "error.json", changeset: changeset)
    end
  end
end

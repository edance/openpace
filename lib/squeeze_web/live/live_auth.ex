defmodule SqueezeWeb.LiveAuth do
  @moduledoc """
  Assign current_user from the session token.
  """
  import Phoenix.LiveView

  alias Squeeze.Guardian

  @token_key "guardian_default_token"

  def on_mount(:default, _params, session, socket) do
    socket = assign_new(socket, :current_user, fn -> get_current_user(session) end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/logout")}
    end
  end

  defp get_current_user(%{@token_key => token}) do
    case Guardian.resource_from_token(token) do
      {:ok, user, _claims} -> user
      _ -> nil
    end
  end
  defp get_current_user(_), do: nil
end

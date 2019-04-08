defmodule SqueezeWeb.NotificationChannel do
  use SqueezeWeb, :channel

  @moduledoc """
  Notification channel
  """

  def join("notification:" <> user_id, _params, socket) do
    if authorized?(user_id, socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(user_id, socket) do
    user_id == "#{socket.assigns.current_user.id}"
  end
end

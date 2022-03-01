defmodule SqueezeWeb.SettingsLive do
  use SqueezeWeb, :live_view

  alias Squeeze.Accounts

  @moduledoc """
  This is the module for the settings live view
  """

  @impl true
  def mount(_params, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)

    socket = assign(socket,
      page_title: "Settings",
      current_user: user,
      changeset: Accounts.change_user(user)
    )

    {:ok, socket}
  end

  def membership_status(%{current_user: user}) do
    case user.subscription_status do
      :free -> "Free Account"
      _status -> "Premium Account"
    end
  end
end

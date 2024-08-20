defmodule SqueezeWeb.SettingsLive do
  use SqueezeWeb, :live_view

  alias Phoenix.LiveView.Helpers
  alias Squeeze.Accounts
  alias Squeeze.Strava.HistoryLoader

  @moduledoc """
  This is the module for the settings live view
  """

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      assign(socket,
        page_title: "Settings",
        current_user: user,
        syncing: false,
        changeset: Accounts.change_user(user)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user(user, user_params) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, gettext("Your preferences have been updated"))
          |> redirect(to: Routes.dashboard_path(socket, :index))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("sync", _params, socket) do
    send(self(), :load_recent_history)
    {:noreply, assign(socket, syncing: true)}
  end

  @impl true
  def handle_info(:load_recent_history, socket) do
    user = socket.assigns.current_user
    credential = Enum.find(user.credentials, &(&1.provider == "strava"))
    HistoryLoader.load_recent(user, credential)

    {:noreply,
     socket
     |> put_flash(:info, "Syncing finished")
     |> assign(syncing: false)}
  end

  def strava_integration?(%{current_user: user}) do
    Enum.any?(user.credentials, &(&1.provider == "strava"))
  end

  def link_item(socket, current_action, text, route_action) do
    base =
      "group flex gap-x-3 rounded-md p-2 pl-3 text-sm font-semibold leading-6 dark:text-white hover:bg-gray-100 hover:bg-gray-50 dark:hover:bg-white/5"

    class_list =
      if current_action == route_action,
        do: "#{base} bg-gray-100 text-indigo-600 dark:bg-white/5",
        else: "#{base} dark:text-white/90"

    Helpers.live_redirect(text, class: class_list, to: Routes.settings_path(socket, route_action))
  end

  def membership_status(%{current_user: user}) do
    case user.subscription_status do
      :free -> "Free Account"
      _status -> "Premium Account"
    end
  end
end

defmodule SqueezeWeb.ActivityLive.Index do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Activities

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    socket = socket
    |> assign(:current_user, user)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    page = params |> Map.get("page", "1") |> String.to_integer()
    socket = socket
    |> assign(:page, page)
    |> assign(:activities, Activities.recent_activities(user, page))

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Activities")
    |> assign(:activity, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    page = socket.assigns.page
    activity = Activities.get_activity!(user, id)
    {:ok, _} = Activities.delete_activity(activity)

    {:noreply, assign(socket, :activities, Activities.recent_activities(user, page))}
  end

  def previous_page(%{page: 1}), do: nil
  def previous_page(%{page: page}), do: page - 1

  def next_page(%{activities: activities}) when length(activities) < 24, do: nil
  def next_page(%{page: page}), do: page + 1
end

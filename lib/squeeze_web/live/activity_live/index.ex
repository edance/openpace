defmodule SqueezeWeb.ActivityLive.Index do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Activities
  alias Squeeze.Activities.Activity

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:current_user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    page = params |> Map.get("page", "1") |> String.to_integer()

    results = Activities.filter_activities(user, %{}, page, 24)

    socket =
      socket
      |> assign(results)

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

  @impl true
  def handle_event("filter", filter_params, socket) do
    page = socket.assigns.page
    result = Activities.filter_activities(socket.assigns.current_user, filter_params, page, 24)
    {:noreply, assign(socket, result)}
  end

  def previous_page(%{page: 1}), do: nil
  def previous_page(%{page: page}), do: page - 1

  def next_page(%{activities: activities}) when length(activities) < 24, do: nil
  def next_page(%{page: page}), do: page + 1

  defp activity_types do
    Activity
    |> Ecto.Enum.mappings(:activity_type)
    |> Enum.map(fn {k, _} -> {format_option(k), k} end)
  end

  defp workout_types do
    Activity
    |> Ecto.Enum.mappings(:workout_type)
    |> Enum.map(fn {k, _} -> {format_option(k), k} end)
  end

  defp format_option(opt) do
    opt
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end

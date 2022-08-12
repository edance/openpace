defmodule SqueezeWeb.Settings.PersonalRecordsFormComponent do
  @moduledoc false

  use SqueezeWeb, :live_component

  alias Phoenix.LiveView.JS
  alias Squeeze.Accounts

  import Squeeze.Distances, only: [distances: 0, distance_name: 2]

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:distance, nil)}
  end

  @impl true
  def handle_event("show_modal", %{"distance" => distance}, socket) do
    case Float.parse(distance) do
      {distance, ""} -> {:noreply, assign(socket, :distance, distance)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("hide_modal", _params, socket) do
    :timer.sleep(:timer.seconds(1)) # Give time for animation to finish
    {:noreply, assign(socket, distance: nil)}
  end

  @impl true
  def handle_event("save", %{"personal_record" => pr}, socket) do
    user = socket.assigns.current_user
    Accounts.put_personal_record(user, pr)
    user = Accounts.get_user!(user.id)
    {:noreply, assign(socket, current_user: user, distance: nil)}
  end

  def pr_at_distance(%{current_user: user}, distance) do
    user.user_prefs.personal_records
    |> Enum.find(&(&1.distance == distance))
  end

  def formatted_pr(assigns, distance) do
    case pr_at_distance(assigns, distance) do
      nil -> "--"
      pr -> format_duration(pr.duration)
    end
  end

  def input_opts(field, idx) do
    [
      id: "user_user_prefs_personal_records_#{idx}_#{field}",
      name: "user[user_prefs][personal_records][#{idx}][#{field}]"
    ]
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.dispatch("hide-modal", to: "#modal")
  end
end

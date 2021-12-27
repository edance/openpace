defmodule SqueezeWeb.RaceLive do
  use SqueezeWeb, :live_view

  @moduledoc """
  This is the module for the calendar live view
  """

  alias Squeeze.Distances
  alias Squeeze.Races
  alias Squeeze.Races.Race

  @impl true
  def mount(_params, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)
    changeset = Races.change_race(%Race{})
    activities = Races.list_race_activities(user)

    socket = assign(socket,
      activities: activities,
      page_title: "Races",
      show_modal: false,
      current_user: user,
      changeset: changeset
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("open_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    # Save the race
    # Add the user to the race
    # Set a goal time
    {:noreply, socket}
  end

  def distances do
    Distances.distances
    |> Enum.map(fn(x) -> {x.name, x.distance} end)
  end
end

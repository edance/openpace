defmodule SqueezeWeb.RaceLive.New do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Ecto.Changeset
  alias Squeeze.Distances
  alias Squeeze.Races
  alias Squeeze.Races.RaceGoal

  @impl true
  def mount(_params, _session, socket) do
    changeset = Races.change_race_goal(%RaceGoal{})
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(current_user: user)
      |> assign(changeset: changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"race_goal" => params}, socket) do
    user = socket.assigns.current_user

    case Races.create_race_goal(user, params) do
      {:ok, _race} ->
        socket =
          socket
          |> redirect(to: Routes.race_path(socket, :index))

        {:noreply, socket}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def distances do
    Distances.distances()
    |> Enum.map(fn x -> {x.name, x.distance} end)
  end
end

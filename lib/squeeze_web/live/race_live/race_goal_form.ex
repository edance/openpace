defmodule SqueezeWeb.RaceLive.RaceGoalForm do
  use SqueezeWeb, :live_component

  alias Squeeze.Distances
  alias Squeeze.Races

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-target={@myself} phx-submit="save">
        <div class="mb-4">
          <.input
            type="text"
            field={f[:race_name]}
            label={gettext("Race Name")}
            placeholder="Boston Marathon"
            autocomplete="off"
          />
        </div>

        <div class="mb-4">
          <.input
            type="select"
            field={f[:distance]}
            label={gettext("Distance")}
            value={trunc(@race_goal.distance)}
            placeholder="Choose a distance"
            options={distances()}
          />
        </div>

        <div class="mb-4">
          <.input type="date" field={f[:race_date]} label={gettext("Race Date")} />
        </div>

        <div class="mb-4">
          <.input field={f[:duration]} type="duration" label={gettext("Goal Time")} />
        </div>

        <div class="mb-4">
          <.input
            type="checkbox"
            field={f[:just_finish]}
            label={gettext("My goal is to just finish")}
          />
        </div>

        <div class="mb-4">
          <.input
            type="textarea"
            field={f[:description]}
            label={gettext("Description")}
            placeholder="Description"
            rows="10"
          />
        </div>
        <.button type="submit">
          Save
        </.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Squeeze.Races.change_race_goal(assigns.race_goal)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"race_goal" => params}, socket) do
    save_race_goal(socket, params)
  end

  defp save_race_goal(socket, params) do
    case Races.update_race_goal(socket.assigns.race_goal, params) do
      {:ok, goal} ->
        notify_parent({:saved, goal})

        {:noreply,
         socket
         |> put_flash(:info, "Race updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp distances do
    Distances.distances()
    |> Enum.map(fn x -> {x.name, x.distance} end)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

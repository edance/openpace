defmodule SqueezeWeb.RaceLive.PaceForm do
  use SqueezeWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.modal
        id="pace-form-modal"
        show
        on_cancel={JS.patch(Routes.race_path(@socket, :show, @race_goal.slug))}
      >
        <div>
          <.form :let={f} for={@form} phx-target={@myself} phx-submit="save">
            <%= inputs_for f, :training_paces, fn pace -> %>
              <.input field={pace[:color]} type="color" />

              <.input field={pace[:name]} />

              <.input field={pace[:min_speed]} />

              <.input field={pace[:max_speed]} />
            <% end %>

            <.button type="submit">
              Save
            </.button>
          </.form>
        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Squeeze.Races.change_race_goal(assigns.race_goal)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:paces, assigns.race_goal.training_paces)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"race_goal" => params}, socket) do
    Squeeze.Races.update_race_goal(socket.assigns.race_goal, params)
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

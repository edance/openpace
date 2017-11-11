defmodule SqueezeWeb.EventController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Event

  plug :authorize_event when action in [:edit, :update, :delete]

  def index(conn, _params) do
    events = Dashboard.list_events(conn.assigns.current_user)
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Dashboard.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    user = conn.assigns.current_user
    case Dashboard.create_event(user, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: event_path(conn, :show, event))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Dashboard.get_event!(id)
    render(conn, "show.html", event: event)
  end

  def edit(conn, _params) do
    event = conn.assigns.event
    changeset = Dashboard.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"event" => event_params}) do
    event = conn.assigns.event

    case Dashboard.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: event_path(conn, :show, event))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    {:ok, _event} = Dashboard.delete_event(conn.assigns.event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: event_path(conn, :index))
  end

  defp authorize_event(conn, _) do
    event = Dashboard.get_event!(conn.params["id"])

    if conn.assigns.current_user.id == event.user_id do
      assign(conn, :event, event)
    else
      conn
      |> put_flash(:error, "You can't modify that event")
      |> redirect(to: event_path(conn, :index))
      |> halt()
    end
  end
end

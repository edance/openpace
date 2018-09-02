defmodule SqueezeWeb.EventController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Event

  require IEx

  plug :authorize_event when action in [:edit, :update, :delete]

  def new(conn, params) do
    date = parse_date(params["date"])
    current_week = String.to_integer(params["current_week"])
    start_date = Date.add(date, 7 * current_week)
    end_date = Date.add(start_date, 7)
    # end_date = start_date + 7
    range = Date.range(start_date, end_date)
    changesets = range
    |> Enum.map(fn(x) -> Dashboard.change_event(%Event{date: x}) end)
    render(conn, "new.html", changesets: changesets)
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

  defp parse_date(date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> Timex.today
    end
  end
end

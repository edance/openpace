defmodule SqueezeWeb.EventController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Event

  require IEx
  require IO

  plug :authorize_event when action in [:edit, :update, :delete]

  def new(conn, params) do
    current_week = String.to_integer(params["current_week"])
    date = parse_date(params["date"])
    start_date = Date.add(date, 7 * current_week)
    changesets = start_date
    |> Date.range(Date.add(start_date, 7))
    |> Enum.map(fn(x) -> Dashboard.change_event(%Event{date: x}) end)
    render(conn, "new.html", changesets: changesets)
  end

  def create(conn, %{"events" => events}) do
    user = conn.assigns.current_user
    events
    |> Enum.map(&Map.merge(&1, %{user_id: user.id}))
    |> Enum.each(&Dashboard.create_event(&1))
    conn
    |> redirect(to: dashboard_path(conn, :index))
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

defmodule SqueezeWeb.Api.V1.EventController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def index(conn, _params) do
    events = Dashboard.list_events(conn.assigns.current_user)
    render(conn, "index.json", events: events)
  end

  def show(conn, %{"id" => id}) do
    event = Dashboard.get_event!(id)
    render(conn, "show.json", event: event)
  end
end

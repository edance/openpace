defmodule SqueezeWeb.Api.V1.EventView do
  use SqueezeWeb, :view

  def render("index.json", %{events: events}) do
    render_many(events, SqueezeWeb.Api.V1.EventView, "event.json")
  end

  def render("show.json", %{event: event}) do
    render_one(event, SqueezeWeb.Api.V1.EventView, "event.json")
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      name: event.name}
  end

end

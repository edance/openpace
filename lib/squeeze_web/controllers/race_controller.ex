defmodule SqueezeWeb.RaceController do
  use SqueezeWeb, :controller

  alias Squeeze.Races

  def show(conn, %{"state" => state, "city" => city, "name" => name}) do
    slug = "/races/#{state}/#{city}/#{name}"
    race = Races.get_race!(slug)
    render(conn, "show.html", race: race)
  end
end

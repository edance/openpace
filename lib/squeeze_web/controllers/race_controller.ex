defmodule SqueezeWeb.RaceController do
  use SqueezeWeb, :controller

  alias Squeeze.Races

  def show(conn, %{"slug" => slug}) do
    race = Races.get_race!(slug)
    render(conn, "show.html", race: race)
  end
end

defmodule SqueezeWeb.Races.ShowLive do
  use SqueezeWeb, :live_view

  @moduledoc """
  Shows a race
  """

  alias Squeeze.Distances
  alias Squeeze.Races

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)
    race_goal = Races.get_race_goal!(slug)

    socket = assign(socket,
      page_title: race_goal.race.name,
      race_goal: race_goal,
      race: race_goal.race,
      current_user: user
    )

    {:ok, socket}
  end

  def distance_name(race, current_user) do
    Distances.distance_name(race.distance, imperial: current_user.user_prefs.imperial)
  end
end

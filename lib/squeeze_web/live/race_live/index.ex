defmodule SqueezeWeb.RaceLive.Index do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Races
  alias Squeeze.Races.RaceGoal

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    changeset = Races.change_race_goal(%RaceGoal{})
    prev_race_goals = Races.list_previous_race_goals(user)
    race_goals = Races.list_upcoming_race_goals(user)

    socket =
      assign(socket,
        page_title: "Races",
        current_user: user,
        changeset: changeset,
        prev_race_goals: prev_race_goals,
        race_goals: race_goals
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"race_goal" => params}, socket) do
    user = socket.assigns.current_user
    Races.create_race_goal(user, params)

    {:noreply, socket}
  end

  def format_start_at_local(start_at) do
    date = Ordinal.ordinalize(start_at.day)

    start_at
    |> Timex.format!("%a %b #{date}, %Y at %-I:%M %p", :strftime)
  end
end

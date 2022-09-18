defmodule SqueezeWeb.RaceLive.Index do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Races
  alias Squeeze.Races.RaceGoal

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    changeset = Races.change_race_goal(%RaceGoal{})
    activities = Races.list_race_activities(user)
    race_goals = Races.list_upcoming_race_goals(user)

    socket = assign(socket,
      activities: activities,
      page_title: "Races",
      current_user: user,
      changeset: changeset,
      race_goals: race_goals
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"race_goal" => params}, socket) do
    user = socket.assigns.current_user
    Races.create_race_goal(user, params)

    # with {:ok, race} <- Races.create_race(params),
    #      {:ok, _goal} <- Races.create_race_goal(user, race) do
    # end
    # Save the race
    # Add the user to the race
    # Set a goal time
    {:noreply, socket}
  end

  def format_start_at_local(start_at) do
    date = Ordinal.ordinalize(start_at.day)
    start_at
    |> Timex.format!("%a %b #{date}, %Y at %-I:%M %p", :strftime)
  end
end

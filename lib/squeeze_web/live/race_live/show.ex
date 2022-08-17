defmodule SqueezeWeb.RaceLive.Show do
  use SqueezeWeb, :live_view

  @moduledoc """
  Shows a race
  """

  alias Squeeze.Dashboard
  alias Squeeze.Distances
  alias Squeeze.RacePredictor
  alias Squeeze.Races

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = socket.assigns.current_user
    race_goal = Races.get_race_goal!(slug)
    vo2_max = vo2_max(race_goal)

    socket = assign(socket,
      page_title: race_goal.race.name,
      race_goal: race_goal,
      race: race_goal.race,
      paces: race_goal.training_paces,
      predictions: predictions(vo2_max),
      vo2_max: vo2_max,
      current_user: user
    )

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    %{race_goal: race_goal, current_user: user} = socket.assigns
    race_date = race_goal.race.start_date
    start_date = race_date |> Timex.shift(weeks: -18) |> Timex.shift(days: 1)
    dates = Date.range(start_date, race_date)

    socket = assign(socket,
      activities: Dashboard.list_activities(user, dates),
      dates: dates
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Races.delete_race_goal(socket.assigns.race_goal)

    socket = socket
    |> redirect(to: Routes.race_path(socket, :index))

    {:noreply, socket}
  end

  def distance_name(distance, current_user) do
    Distances.distance_name(distance, imperial: current_user.user_prefs.imperial)
  end

  defp vo2_max(%{duration: nil}), do: nil
  defp vo2_max(%{distance: distance, duration: duration}) do
    RacePredictor.estimated_vo2max(distance, duration)
  end

  defp predictions(nil), do: nil
  defp predictions(vo2_max) do
    RacePredictor.predict_all_race_times(vo2_max)
  end
end

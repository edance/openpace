defmodule SqueezeWeb.RaceLive.Show do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Distances
  alias Squeeze.RacePredictor
  alias Squeeze.Races

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = socket.assigns.current_user
    race_goal = Races.get_race_goal!(slug)
    vo2_max = vo2_max(race_goal)

    socket =
      assign(socket,
        page_title: race_goal.race_name,
        race_goal: race_goal,
        paces: race_goal.training_paces,
        predictions: predictions(vo2_max),
        vo2_max: vo2_max,
        current_user: user
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Races.delete_race_goal(socket.assigns.race_goal)

    socket =
      socket
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

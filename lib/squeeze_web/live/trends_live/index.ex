defmodule SqueezeWeb.TrendsLive.Index do
  use SqueezeWeb, :live_view

  alias Phoenix.LiveView.JS
  alias Squeeze.Activities
  alias Squeeze.Distances
  alias Squeeze.Stats
  alias Squeeze.Velocity

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      assign(socket,
        years: Stats.years_active(user)
      )

    if connected?(socket) do
      send(self(), :fetch_summaries)
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("open-activity", %{"slug" => slug}, socket) do
    {:noreply, push_redirect(socket, to: Routes.activity_path(socket, :show, slug))}
  end

  defp apply_action(socket, :show, %{"year" => year}) do
    socket
    |> assign(:page_title, "#{year} Trends")
    |> assign(:year, year)
    |> push_event("update-year", %{year: year})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All-Time Trends")
    |> assign(:year, nil)
    |> push_event("update-year", %{year: nil})
  end

  @impl true
  def handle_info(:fetch_summaries, socket) do
    user = socket.assigns.current_user
    summaries = list_summaries(user)
    {:noreply, push_event(socket, "summaries", %{summaries: summaries})}
  end

  defp list_summaries(user) do
    imperial = user.user_prefs.imperial

    user
    |> Activities.list_activity_summaries()
    |> Enum.map(fn a ->
      a
      |> Map.merge(%{
        distance: Distances.to_float(a.distance, imperial: imperial),
        year: a.start_at_local.year,
        month: a.start_at_local.month,
        velocity: velocity(a),
        pace: Velocity.to_float(velocity(a), imperial: imperial),
        elevation_gain: Distances.to_feet(a.elevation_gain, imperial: imperial)
      })
    end)
  end

  defp velocity(%{distance: nil}), do: 0.0
  defp velocity(%{duration: nil}), do: 0.0
  defp velocity(%{duration: 0}), do: 0.0

  defp velocity(%{distance: distance, duration: duration}) do
    distance / duration
  end

  def btn_group_class(active) do
    if active do
      "relative inline-flex items-center bg-indigo-500 text-white px-3 py-2 text-sm font-semibold ring-1 ring-inset ring-indigo-500 hover:bg-indigo-700 focus:z-10"
    else
      "relative inline-flex items-center bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-10"
    end
  end

  def btn_dropdown_class(active) do
    if active do
      "block px-4 py-2 text-sm text-white bg-indigo-500"
    else
      "block px-4 py-2 text-sm text-gray-700"
    end
  end
end

defmodule SqueezeWeb.TrendsLive.Index do
  use SqueezeWeb, :live_view

  alias Squeeze.Dashboard
  alias Squeeze.Distances
  alias Squeeze.Velocity

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    user = socket.assigns.current_user
    summaries = list_summaries(user)
    {:noreply, push_event(socket, "summaries", %{summaries: summaries})}
  end

  defp list_summaries(user) do
    imperial = user.user_prefs.imperial

    user
    |> Dashboard.list_activity_summaries()
    |> Enum.map(fn (a) ->
      a
      |> Map.merge(
        %{
          distance: Distances.to_float(a.distance, imperial: imperial),
          year: a.start_at_local.year,
          month: a.start_at_local.month,
          velocity: velocity(a),
          pace: Velocity.to_float(velocity(a), imperial: imperial)
        }
      )
    end)
  end

  defp velocity(%{distance: nil}), do: 0.0
  defp velocity(%{duration: nil}), do: 0.0
  defp velocity(%{duration: 0}), do: 0.0
  defp velocity(%{distance: distance, duration: duration}) do
    distance / duration
  end
end

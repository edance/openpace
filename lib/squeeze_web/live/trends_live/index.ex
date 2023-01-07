defmodule SqueezeWeb.TrendsLive.Index do
  use SqueezeWeb, :live_view

  alias Squeeze.Dashboard

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    user = socket.assigns.current_user
    summaries = Dashboard.list_activity_summaries(user)
    {:noreply, push_event(socket, "summaries", %{summaries: summaries})}
  end
end

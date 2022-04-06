defmodule SqueezeWeb.Dashboard.LoadHistoryComponent do
  use SqueezeWeb, :live_component

  def show_component?(%{current_user: user}) do
    credential = Enum.find(user.credentials, &(&1.provider == "strava"))
    credential && is_nil(credential.sync_at)
  end

  @impl true
  def handle_event("load_history", _params, socket) do
    send(self(), :load_strava_history)
    {:noreply, assign(socket, loading: true)}
  end

end

defmodule SqueezeWeb.Races.ShowLive do
  use SqueezeWeb, :live_view

  @moduledoc """
  Shows a race
  """

  @impl true
  def mount(_params, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)

    socket = socket
    |> assign(current_user: user)

    {:ok, socket}
  end
end

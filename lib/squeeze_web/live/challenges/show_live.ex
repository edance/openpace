defmodule SqueezeWeb.Challenges.ShowLive do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Challenges

  @impl true
  def mount(%{"id" => slug}, _session, socket) do
    user = socket.assigns.current_user
    challenge = Challenges.get_challenge_by_slug!(slug)

    socket =
      socket
      |> assign(:current_user, user)
      |> assign(challenge: challenge)

    {:ok, socket}
  end
end

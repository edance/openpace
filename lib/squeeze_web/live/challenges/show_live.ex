defmodule SqueezeWeb.Challenges.ShowLive do
  use SqueezeWeb, :live_view

  alias Squeeze.Challenges

  @impl true
  def mount(%{"id" => slug}, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)
    challenge = Challenges.get_challenge_by_slug!(slug)

    socket = socket
    |> assign(:current_user, user)
    |> assign(challenge: challenge)

    {:ok, socket}
  end
end

defmodule SqueezeWeb.Challenges.ShowLive do
  use SqueezeWeb, :live_view

  alias Squeeze.Challenges

  @impl true
  def mount(%{"id" => slug}, session, socket) do
    challenge = Challenges.get_challenge_by_slug!(slug)

    socket = socket
    |> assign_new(:current_user, fn -> get_current_user(session) end)
    |> assign(challenge: challenge)

    {:ok, socket}
  end
end

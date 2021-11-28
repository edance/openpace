defmodule SqueezeWeb.ChallengeLive do
  use SqueezeWeb, :live_view

  alias Squeeze.Challenges
  alias Squeeze.Guardian
  alias Squeeze.TimeHelper

  @impl true
  def mount(_params, %{"guardian_default_token" => token}, socket) do
    {:ok, user, _claims} = Guardian.resource_from_token(token)
    date = TimeHelper.today(user) |> Timex.shift(days: -3)
    socket = socket
    |> assign(current_user: user)
    |> assign(challenges: Challenges.list_challenges(user, ends_after: date))
    |> assign(podium_finishes: Challenges.podium_finishes(user))

    {:ok, socket}
  end
end

defmodule SqueezeWeb.ChallengeLive do
  use SqueezeWeb, :live_view
  @moduledoc false

  alias Squeeze.Challenges
  alias Squeeze.Guardian
  alias Squeeze.TimeHelper

  @impl true
  def mount(_params, %{"guardian_default_token" => token}, socket) do
    {:ok, user, _claims} = Guardian.resource_from_token(token)
    date = TimeHelper.today(user) |> Timex.shift(days: -3)

    socket =
      socket
      |> assign(page_title: "Challenges")
      |> assign(current_user: user)
      |> assign(challenges: Challenges.list_challenges(user, ends_after: date))
      |> assign(podium_finishes: Challenges.podium_finishes(user))

    {:ok, socket}
  end

  def podium_icon(%{challenge: challenge, current_user: user}) do
    case Enum.find_index(challenge.scores, &(&1.user_id == user.id)) do
      0 -> "whh:medalgold"
      1 -> "whh:medalsilver"
      2 -> "whh:medalbronze"
      _ -> nil
    end
  end

  def podium_finish(%{challenge: challenge, current_user: user}) do
    case Enum.find_index(challenge.scores, &(&1.user_id == user.id)) do
      0 -> "1st Place"
      1 -> "2nd Place"
      2 -> "3rd Place"
      _ -> nil
    end
  end

  def challenge_relative_date(%{challenge: challenge, current_user: user}) do
    now = Timex.now()
    start_at = TimeHelper.beginning_of_day(user, challenge.start_date)
    end_at = TimeHelper.end_of_day(user, challenge.end_date)

    cond do
      Timex.after?(start_at, now) ->
        "Starts #{relative_time(start_at)}"

      Timex.before?(end_at, now) ->
        "Ended #{relative_time(end_at)}"

      true ->
        "Ends #{relative_time(end_at)}"
    end
  end

  def podium_item(assigns) do
    ~H"""
    <div class="flex items-start px-0 my-5 text-gray-900 dark:text-white">
      <div class="pt-4 flex-shrink-0">
        <div class="text-xl w-6">
          <span class="iconify h-6 w-6" data-icon={podium_icon(assigns)} data-inline="false"></span>
        </div>
      </div>
      <div class="pl-4 pb-2 flex-grow">
        <%= live_redirect(@challenge.name,
          to: Routes.challenge_path(@socket, :show, @challenge.slug),
          class: "text-gray-900 dark:text-white font-semibold"
        ) %>
        <p class="mt-0 mb-1 text-xs opacity-60 font-semibold">
          <%= podium_finish(assigns) %> &middot; <%= challenge_type(assigns) %> &middot; <%= challenge_relative_date(
            assigns
          ) %>
        </p>
      </div>
    </div>
    """
  end
end

defmodule SqueezeWeb.ChallengeController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges
  alias Squeeze.Notifications

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, user) do
    challenges = Challenges.list_current_challenges(user)
    render(conn, "index.html", challenges: challenges)
  end

  def show(conn, %{"id" => slug}, _user) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    render(conn, "show.html", %{challenge: challenge})
  end

  def join(conn, %{"id" => slug}, user) do
    challenge = Challenges.get_challenge_by_slug!(slug)

    with {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do
      Notifications.notify_user_joined(challenge, user)
      redirect(conn, to: Routes.dashboard_path(conn, :index))
    end
  end
end

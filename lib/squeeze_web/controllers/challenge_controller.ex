defmodule SqueezeWeb.ChallengeController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges

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
end

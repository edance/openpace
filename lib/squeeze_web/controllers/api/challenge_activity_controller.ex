defmodule SqueezeWeb.Api.ChallengeActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges

  def index(conn, %{"id" => slug}) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    activities = Challenges.list_challenge_activities(challenge)
    render(conn, "index.json", %{challenge_activities: activities})
  end
end

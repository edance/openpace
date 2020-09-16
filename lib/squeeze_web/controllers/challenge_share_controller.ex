defmodule SqueezeWeb.ChallengeShareController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges

  def show(conn, %{"slug" => slug}) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    render(conn, "show.html", challenge: challenge)
  end
end

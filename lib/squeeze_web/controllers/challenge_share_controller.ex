defmodule SqueezeWeb.ChallengeShareController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Challenges

  def show(conn, %{"slug" => slug}) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    render(conn, "show.html", challenge: challenge, page_title: "Challenge Invite")
  end
end

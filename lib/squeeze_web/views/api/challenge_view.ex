defmodule SqueezeWeb.Api.ChallengeView do
  def render("index.json", %{challenges: challenges}) do
    %{challenges: render_many(challenges, SqueezeWeb.Api.ChallengeView, "challenge.json")}
  end

  def render("show.json", %{challenge: challenge}) do
    render_one(challenge, SqueezeWeb.Api.ChallengeView, "challenge.json")
  end

  def render("challenge.json", %{challenge: challenge}) do
    %{
      id: challenge.id,
      name: challenge.name,
      start_at: challenge.start_at,
      end_at: challenge.end_at,
      activity_type: challenge.activity_type,
      challenge_type: challenge.challenge_type,
      timeline: challenge.timeline
    }
  end
end

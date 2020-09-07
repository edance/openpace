defmodule SqueezeWeb.Api.ChallengeView do
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

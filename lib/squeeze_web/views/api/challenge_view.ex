defmodule SqueezeWeb.Api.ChallengeView do
  use SqueezeWeb, :view
  @moduledoc false

  def render("index.json", %{challenges: challenges}) do
    %{challenges: render_many(challenges, SqueezeWeb.Api.ChallengeView, "challenge.json")}
  end

  def render("show.json", %{challenge: challenge}) do
    render_one(challenge, SqueezeWeb.Api.ChallengeView, "challenge.json")
  end

  def render("status.json", %{joined: joined}) do
    %{
      joined: joined
    }
  end

  def render("challenge.json", %{challenge: challenge}) do
    %{
      slug: challenge.slug,
      name: challenge.name,
      start_date: challenge.start_date,
      end_date: challenge.end_date,
      activity_type: challenge.activity_type,
      challenge_type: challenge.challenge_type,
      timeline: challenge.timeline,
      segment_id: challenge.segment_id,
      polyline: challenge.polyline,
      scores:
        render_many(challenge.scores, SqueezeWeb.Api.ChallengeView, "score.json", as: :score)
    }
  end

  def render("leaderboard.json", %{challenge: challenge, scores: scores}) do
    %{
      scores: render_many(scores, SqueezeWeb.Api.ChallengeView, "score.json", as: :score),
      challenge: render_one(challenge, SqueezeWeb.Api.ChallengeView, "challenge.json")
    }
  end

  def render("score.json", %{score: score}) do
    %{
      amount: score.amount,
      user_id: score.user_id,
      first_name: score.user.first_name,
      last_name: score.user.last_name,
      avatar: score.user.avatar,
      updated_at: score.updated_at
    }
  end
end

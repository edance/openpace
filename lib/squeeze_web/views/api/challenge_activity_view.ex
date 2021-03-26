defmodule SqueezeWeb.Api.ChallengeActivityView do
  use SqueezeWeb, :view

  def render("index.json", %{challenge_activities: challenge_activities}) do
    %{challenge_activities: render_many(challenge_activities, SqueezeWeb.Api.ChallengeActivityView, "challenge_activity.json")}
  end

  def render("challenge_activity.json", %{challenge_activity: challenge_activity}) do
    activity = challenge_activity.activity

    %{
      id: challenge_activity.id,
      amount: challenge_activity.amount,
      activity: render_one(activity, SqueezeWeb.Api.ActivityView, "activity.json", as: :activity),
      user: render_one(activity.user, SqueezeWeb.Api.UserView, "user.json", as: :user)
    }
  end
end

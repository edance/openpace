defmodule SqueezeWeb.Api.ActivityView do
  use SqueezeWeb, :view

  def render("activities.json", %{activities: activities}) do
    %{
      activities: render_many(activities, SqueezeWeb.Api.ActivityView, "activity.json")
    }
  end

  def render("activity.json", %{activity: activity}) do
    %{
      id: activity.id,
      activity_type: activity.activity_type,
      name: activity.name,
      workout_type: activity.workout_type,
      distance: activity.distance,
      start_at: activity.start_at,
      duration: activity.duration,
      elevation_gain: activity.elevation_gain,
      external_id: activity.external_id,
      polyline: activity.polyline
    }
  end
end

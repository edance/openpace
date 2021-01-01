defmodule SqueezeWeb.Api.SegmentView do
  use SqueezeWeb, :view

  def render("starred.json", %{segments: segments}) do
    render_many(segments, SqueezeWeb.Api.SegmentView, "segment.json", as: :segment)
  end

  def render("segment.json", %{segment: segment}) do
    %{
      activity_type: nil,
      athlete_pr_effort: nil,
      average_grade: nil,
      city: nil,
      climb_category: nil,
      country: nil,
      distance: segment.distance,
      elevation_high: nil,
      elevation_low: nil,
      end_latlng: nil,
      id: segment.id,
      maximum_grade: nil,
      name: segment.name,
      private: nil,
      start_latlng: nil,
      state: nil
    }
  end
end

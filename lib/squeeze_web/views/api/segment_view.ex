defmodule SqueezeWeb.Api.SegmentView do
  use SqueezeWeb, :view
  @moduledoc false

  def render("starred.json", %{segments: segments}) do
    %{
      segments: render_many(segments, SqueezeWeb.Api.SegmentView, "summary_segment.json", as: :segment)
    }
  end

  def render("summary_segment.json", %{segment: segment}) do
    %{
      activity_type: segment.activity_type,
      average_grade: segment.average_grade,
      city: segment.city,
      climb_category: segment.climb_category,
      country: segment.country,
      distance: segment.distance,
      elevation_high: segment.elevation_high,
      elevation_low: segment.elevation_low,
      end_latlng: segment.end_latlng,
      id: segment.id,
      maximum_grade: segment.maximum_grade,
      name: segment.name,
      private: segment.private,
      start_latlng: segment.start_latlng,
      state: segment.state
    }
  end

  def render("segment.json", %{segment: segment}) do
    %{
      activity_type: segment.activity_type,
      average_grade: segment.average_grade,
      city: segment.city,
      climb_category: segment.climb_category,
      country: segment.country,
      distance: segment.distance,
      elevation_high: segment.elevation_high,
      elevation_low: segment.elevation_low,
      end_latlng: segment.end_latlng,
      id: segment.id,
      maximum_grade: segment.maximum_grade,
      name: segment.name,
      private: segment.private,
      start_latlng: segment.start_latlng,
      state: segment.state,
      polyline: segment.map.polyline,
    }
  end
end

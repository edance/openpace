defmodule SqueezeWeb.Challenges.StaticMapComponent do
  @moduledoc """
  A component for the card of a segment challenge which includes a map and a description of the polyline.
  """
  use SqueezeWeb, :live_component

  alias SqueezeWeb.MapboxStaticMap

  def map_url(polyline) do
    opts = [
      height: 300,
      width: 500,
      show_pins: true,
      outline_color: "#FFFFFF"
    ]
    MapboxStaticMap.map_url(polyline, opts)
  end

  def description(user, segment) do
    distance = format_distance(segment.distance, user.user_prefs)
    "#{distance} - #{segment.city}, #{segment.state}"
  end
end

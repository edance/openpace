defmodule SqueezeWeb.Challenges.StaticMapComponent do
  use SqueezeWeb, :live_component

  alias SqueezeWeb.MapboxStaticMap

  def map_url(polyline) do
    MapboxStaticMap.map_url(polyline, height: 512, width: 512, show_pins: true)
  end
end

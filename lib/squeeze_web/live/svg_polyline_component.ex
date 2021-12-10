defmodule SqueezeWeb.SvgPolylineComponent do
  @moduledoc """
  SVG Polyline component. Builds an svg path on the server based on a polyline.

  Converted from JS here: https://stackoverflow.com/questions/46646901/convert-google-maps-polyline-to-svg
  """

  use SqueezeWeb, :live_component

  def svg_path(nil), do: nil
  def svg_path(polyline) do
    coords = Polyline.decode(polyline)
    points = coords |> Enum.map(&coord_to_point/1)
    min_x = points |> Enum.map(&(&1.x)) |> Enum.min()
    min_y = points |> Enum.map(&(&1.y)) |> Enum.min()
    max_x = points |> Enum.map(&(&1.x)) |> Enum.max()
    max_y = points |> Enum.map(&(&1.y)) |> Enum.max()
    svg_path = points |> Enum.map_join(" ", &("#{&1.x},#{&1.y}"))
    stroke_width = Enum.max([(max_x - min_x) * 0.01, (max_y - min_y) * 0.01])

    %{
      path: "M#{svg_path}",
      x: min_x - stroke_width,
      y: min_y - stroke_width,
      width: max_x - min_x + stroke_width * 2,
      height: max_y - min_y + stroke_width * 2,
      stroke_width: stroke_width
    }
  end

  def coord_to_point({lon, lat}) do
    %{
      x: (lon + 180) * (256 / 360),
      y: (256 / 2) - (256 * :math.log(:math.tan((:math.pi() / 4) + ((lat * :math.pi() / 180) / 2))) / (2 * :math.pi()))
    }
  end
end

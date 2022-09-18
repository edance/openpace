defmodule SqueezeWeb.MapboxStaticMap do
  @moduledoc """
  Utility library to create a map url for mapbox which has a gradient line.

  Converted from JS here: https://blog.mapbox.com/generate-gradient-lines-with-the-static-image-api-368eb28068a3
  """

  @doc """
  Get a mapbox static url for a polyline

  ## Options
  * height (integer): height of the image
  * width (integer): width of the image
  * show_pins (boolean): show or hide the start and end markers
  * start_color (string): start of the gradient color in hex (example "#FF512F")
  * end_color (string): end of the gradient color in hex (example "#FF512F")
  * stroke_width (integer): width of the path
  * style (string): mapbox style of map (default "dark-v10")
  * outline_color (color): outline the path with this color if present
  """
  def map_url(polyline, opts \\ []) do
    height = Keyword.get(opts, :height, 256)
    width = Keyword.get(opts, :width, 256)
    style = Keyword.get(opts, :style, "dark-v10")
    encoded_path = URI.encode(make_path(polyline, opts), &URI.char_unreserved?(&1))

    "https://api.mapbox.com/styles/v1/mapbox/#{style}/static/#{encoded_path}/auto/#{width}x#{height}@2x?access_token=#{token()}"
  end

  defp make_path(polyline, opts) do
    coords = decode_polyline(polyline)

    [
      make_outline_path(coords, opts),
      make_path_with_gradient(coords, opts),
      make_pins(coords, opts)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(",")
  end

  def token do
    Application.get_env(:squeeze, :mapbox_access_token)
  end

  defp make_outline_path(coords, opts) do
    case Keyword.get(opts, :outline_color, nil) do
      nil -> nil
      color ->
        stroke_width = Keyword.get(opts, :stroke_width, 4) + 2 # one pixel padding on each side
        color = color |> String.replace("#", "")
        "path-#{stroke_width}+#{color}(#{Polyline.encode(coords)})"
    end
  end

  defp make_path_with_gradient(coords, opts) do
    start_color = Keyword.get(opts, :start_color, "#FF512F")
    end_color = Keyword.get(opts, :end_color, "#F09819")
    stroke_width = Keyword.get(opts, :stroke_width, 4)

    color_a = hex_str_to_rgb(start_color)
    color_b = hex_str_to_rgb(end_color)
    spectrum_colors = create_spectrum(color_a, color_b, length(coords) - 1)

    [first_coord | coords] = coords
    {paths, _} = Enum.map_reduce(coords, first_coord, fn c2, c1 -> {[c1, c2], c2} end)

    # format from https://docs.mapbox.com/api/maps/#path
    paths
    |> Enum.zip(spectrum_colors)
    |> Enum.map_join(",", fn {path, color} -> "path-#{stroke_width}+#{color}(#{Polyline.encode(path)})" end)
  end

  defp make_pins(coords, opts) do
    if Keyword.get(opts, :show_pins, false) do
      start_color = Keyword.get(opts, :start_color, "#FF512F")
      end_color = Keyword.get(opts, :end_color, "#F09819")
      color_a = hex_str_to_rgb(start_color)
      color_b = hex_str_to_rgb(end_color)
      {lon1, lat1} = List.first(coords)
      {lon2, lat2} = List.last(coords)

      Enum.join([
        "pin-s-a+#{rgb_to_hex_str(color_a)}(#{lon1},#{lat1})",
        "pin-s-b+#{rgb_to_hex_str(color_b)}(#{lon2},#{lat2})"
      ], ",")
    else
      nil
    end
  end

  defp decode_polyline(polyline) do
    coords = Polyline.decode(polyline)
    length = length(coords)

    if length > 100 do
      Enum.take_every(coords, round(:math.ceil(length / 100)))
    else
      coords
    end
  end

  defp dec_to_hex(dec) do
    pad = if dec < 16 do
      "0"
    else
      ""
    end
    "#{pad}#{Integer.to_string(dec, 16)}"
  end

  defp hex_to_dec(hex) do
    {x, ""} = Integer.parse(hex, 16)
    x
  end

  defp rgb_to_hex_str(rgb) do
    rgb
    |> Enum.map_join(&dec_to_hex/1)
  end

  defp hex_str_to_rgb(hex_str) do
    hex_str
    |> String.replace("#", "")
    |> String.graphemes()
    |> Enum.chunk_every(2)
    |> Enum.map(fn ([a, b])  -> hex_to_dec("#{a}#{b}") end)
  end

  defp create_spectrum(start_rgb, end_rgb, steps) do
    [s_red, s_green, s_blue] = start_rgb
    [e_red, e_green, e_blue] = end_rgb

    Enum.map(0..steps, fn i ->
      r = round(((e_red - s_red) * i) / steps) + s_red
      g = round(((e_green - s_green) * i) / steps) + s_green
      b = round(((e_blue - s_blue) * i) / steps) + s_blue
      rgb_to_hex_str([r, g, b])
    end)
  end
end

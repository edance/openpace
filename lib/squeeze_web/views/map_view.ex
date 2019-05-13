defmodule SqueezeWeb.MapView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def coordinates(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&map_coordinate/1)
    |> Poison.encode!()
  end

  def layer(%{trackpoints: trackpoints}) do
    %{
      id: "trackpoints",
      type: "circle",
      source: %{
        type: "geojson",
        data: %{
          type: "FeatureCollection",
          features: trackpoints |> Enum.map(&feature/1)
        }
      },
      paint: paint()
    }
    |> Jason.encode!()
  end

  def markers(%{current_user: user, trackpoints: trackpoints}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.group_by(&Distances.to_int(&1.distance, imperial: imperial))
    |> Enum.map(fn({_, v}) -> List.first(v) end)
    |> Enum.map(&map_coordinate/1)
    |> Poison.encode!()
  end

  def map_coordinate(%{coordinates: nil}), do: nil
  def map_coordinate(%{coordinates: coordinates}) do
    [coordinates["lon"], coordinates["lat"]]
  end

  defp feature(trackpoint) do
    %{
      type: "Feature",
      properties: %{
        color: color(trackpoint.velocity)
      },
      geometry: %{
        type: "Point",
        coordinates: map_coordinate(trackpoint)
      }
    }
  end

  defp color(velocity) do
    gradient = gradient()
    idx = Enum.min([trunc((velocity / 5.0) * 10), length(gradient) - 1])
    Enum.at(gradient, idx)
  end

  defp gradient do
    [
      "#BF0900",
      "#C23200",
      "#C65C00",
      "#CA8800",
      "#CEB500",
      "#BFD200",
      "#96D500",
      "#6CD900",
      "#40DD00",
      "#13E100",
      "#00E51C"
    ]
  end

  defp paint do
    %{
      "circle-radius": %{
        base: 1.75,
        stops: [[12, 2], [22, 180]]
      },
      "circle-color": ["get", "color"]
    }
  end
end

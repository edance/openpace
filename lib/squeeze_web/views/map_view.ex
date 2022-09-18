defmodule SqueezeWeb.MapView do
  use SqueezeWeb, :view
  @moduledoc false

  alias Squeeze.Distances

  def coordinates(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&map_coordinate/1)
    |> Jason.encode!()
  end

  def coordinates(%{race: race}), do: coordinates(race)

  def layer(%{trackpoints: trackpoints, activity: activity}) do
    %{
      id: "trackpoints",
      type: "circle",
      source: %{
        type: "geojson",
        data: %{
          type: "FeatureCollection",
          features: Enum.map(trackpoints, &(feature(&1, average_velocity(activity))))
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
    |> Jason.encode!()
  end

  def map_coordinate(%{coordinates: nil}), do: nil
  def map_coordinate(%{coordinates: coordinates}) do
    [coordinates["lon"], coordinates["lat"]]
  end

  def gradient do
    [
      %{factor: 0.88, color: "#9E1A00"},
      %{factor: 0.91, color: "#FF2A00"},
      %{factor: 0.94, color: "#E86F0C"},
      %{factor: 0.97, color: "#FF9C0D"},
      %{factor: 1.00, color: "#FFCA00"},
      %{factor: 1.03, color: "#FFD600"},
      %{factor: 1.06, color: "#C4E800"},
      %{factor: 1.09, color: "#9DE80C"},
      %{factor: 1.12, color: "#7EFF00"},
      %{factor: 1.15, color: "#32AB00"},
      %{factor: 1.18, color: "#1E8400"}
    ]
  end

  def pace(%{activity: activity, current_user: user}) do
    imperial = user.user_prefs.imperial
    distance = Distances.to_float(activity.distance, imperial: imperial)
    trunc(activity.duration / distance)
  end

  defp feature(trackpoint, avg_velocity) do
    %{
      type: "Feature",
      properties: %{
        color: color(trackpoint.velocity, avg_velocity)
      },
      geometry: %{
        type: "Point",
        coordinates: map_coordinate(trackpoint)
      }
    }
  end

  defp color(velocity, avg_velocity) do
    case Enum.find(gradient(), &(velocity < avg_velocity * &1.factor)) do
      %{color: color} -> color
      _ -> "#1E8400"
    end
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

  defp average_velocity(activity) do
    activity.distance / activity.duration
  end
end

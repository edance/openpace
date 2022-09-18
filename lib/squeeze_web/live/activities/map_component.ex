defmodule SqueezeWeb.Activities.MapComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.Distances

  def coordinates(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&map_coordinate/1)
    |> Jason.encode!()
  end

  def show_pace?(%{activity: activity}) do
    activity.type == "Run"
  end

  def path_layer(%{trackpoints: trackpoints, activity: activity}) do
    avg_velocity = average_velocity(activity)
    [first_tp | trackpoints] = trackpoints
    {paths, _} = Enum.map_reduce(trackpoints, first_tp, fn c2, c1 -> {[c1, c2], c2} end)

    %{
      id: "LineString",
      type: "line",
      source: %{
        type: "geojson",
        data: %{
          type: "FeatureCollection",
          features: Enum.map(paths, &(path_feature(&1, avg_velocity)))
        }
      },
      layout: %{
        "line-join": "round",
        "line-cap": "round"
      },
      paint: %{
        "line-color": ["get", "color"],
        "line-width": 5
      }
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

  defp path_feature(path, avg_velocity) do
    tp = List.first(path)
    %{
      properties: %{
        color: color(tp.velocity, avg_velocity)
      },
      geometry: %{
        type: "LineString",
        coordinates: Enum.map(path, &map_coordinate/1)
      }
    }
  end

  defp color(velocity, avg_velocity) do
    case Enum.find(gradient(), &(velocity < avg_velocity * &1.factor)) do
      %{color: color} -> color
      _ -> "#1E8400"
    end
  end

  defp average_velocity(activity) do
    activity.distance / activity.duration
  end
end

defmodule Squeeze.FileParser.FitImport do
  @moduledoc """
  Parses FIT files and returns metadata like distance, duration, trackpoints, and laps.
  """

  import Squeeze.Utils, only: [cast_float: 1, cast_int: 1]

  def import_from_file(filename) do
    records = Squeeze.RustFit.parse_fit_file(filename)

    session_data =
      records
      |> Enum.find(&(&1.kind == "session"))
      |> Map.get(:fields, [])
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, value)
      end)

    start_at = start_at(session_data)
    trackpoints = trackpoints(records, start_at)

    %{
      type: type(session_data),
      activity_type: activity_type(session_data),
      distance: session_data |> Map.get("total_distance") |> cast_float(),
      duration: session_data |> Map.get("total_elapsed_time") |> cast_int(),
      moving_time: session_data |> Map.get("total_elapsed_time") |> cast_int(),
      elapsed_time: session_data |> Map.get("total_elapsed_time") |> cast_int(),
      start_at: start_at,
      # TODO: This should be the local time
      start_at_local: start_at,
      elevation_gain: session_data |> Map.get("total_ascent") |> cast_float(),
      polyline: polyline(trackpoints),
      trackpoints: trackpoints,
      laps: laps(records)
    }
  end

  defp type(session_data) do
    case Map.get(session_data, "sport") do
      "running" -> "Run"
      "cycling" -> "Ride"
      "swimming" -> "Swim"
      sport -> sport
    end
  end

  defp activity_type(session_data) do
    case Map.get(session_data, "sport") do
      "running" -> :run
      "cycling" -> :bike
      "swimming" -> :swim
      _sport -> :other
    end
  end

  defp start_at(session_data) do
    start_str = Map.get(session_data, "start_time")
    parse_timestamp(start_str)
  end

  defp polyline(trackpoints) do
    trackpoints
    |> Enum.map(& &1.coordinates)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&{&1.lon, &1.lat})
    |> Polyline.encode()
  end

  defp trackpoints(records, start_at) do
    records
    |> Enum.filter(&(&1.kind == "record"))
    |> Enum.map(fn record ->
      obj =
        record
        |> Map.get(:fields, [])
        |> Enum.reduce(%{}, fn {key, value}, acc ->
          Map.put(acc, key, value)
        end)

      timestamp = parse_timestamp(obj["timestamp"])

      %{
        altitude: map_get_by_priority(obj, ["enhanced_altitude", "altitude"]) |> cast_float(),
        cadence: cast_int(obj["cadence"]),
        coordinates: coordinates(obj),
        distance: cast_float(obj["distance"]),
        heartrate: cast_int(obj["heart_rate"]),
        velocity: map_get_by_priority(obj, ["enhanced_speed", "speed"]) |> cast_float(),
        moving: true,
        time: Timex.diff(timestamp, start_at, :seconds)
      }
    end)
  end

  defp laps(records) do
    records
    |> Enum.filter(&(&1.kind == "lap"))
    |> Enum.map(fn obj ->
      lap =
        obj
        |> Map.get(:fields, [])
        |> Enum.reduce(%{}, fn {key, value}, acc ->
          Map.put(acc, key, value)
        end)

      start_time = parse_timestamp(lap["start_time"])

      %{
        average_cadence:
          map_get_by_priority(lap, ["avg_running_cadence", "avg_cadence"]) |> cast_float(),
        average_speed:
          map_get_by_priority(lap, ["enhanced_avg_speed", "avg_speed"]) |> cast_float(),
        distance: cast_float(lap["total_distance"]),
        elapsed_time: cast_int(lap["total_elapsed_time"]),
        # TODO: This should be the start index of the lap
        start_index: 0,
        # TODO: This should be the end index of the lap
        end_index: 0,
        lap_index: cast_int(lap["message_index"]),
        max_speed: map_get_by_priority(lap, ["enhanced_max_speed", "max_speed"]) |> cast_float(),
        moving_time: cast_int(lap["total_elapsed_time"]),
        name: lap["event"],
        split: cast_int(lap["message_index"]) + 1,
        start_date: start_time |> to_naive_datetime(),
        start_date_local: start_time |> to_naive_datetime(),
        total_elevation_gain: cast_float(lap["total_ascent"])
      }
    end)
  end

  defp to_naive_datetime(datetime) do
    datetime
    |> Timex.to_naive_datetime()
    |> NaiveDateTime.truncate(:second)
  end

  defp parse_timestamp(timestamp) do
    with {:error, _} <- Timex.parse(timestamp, "{ISO:Extended:Z}"),
         {:ok, timestamp} <- Timex.parse(timestamp, "{YYYY}-{M}-{D} {h24}:{m}:{s} {Z:}") do
      timestamp
    else
      {:ok, timestamp} -> timestamp
      {:error, _} -> nil
    end
  end

  defp coordinates(record) do
    lat = record["position_lat"] |> cast_float()
    lon = record["position_long"] |> cast_float()

    if lat && lon do
      %{
        lat: lat / 11_930_465,
        lon: lon / 11_930_465
      }
    else
      nil
    end
  end

  def map_get_by_priority(map, [key | rest]) do
    case Map.get(map, key) do
      nil -> map_get_by_priority(map, rest)
      value -> value
    end
  end

  def map_get_by_priority(_, []), do: nil
end

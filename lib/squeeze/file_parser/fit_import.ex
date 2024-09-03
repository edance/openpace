defmodule Squeeze.FileParser.FitImport do
  @moduledoc """
  Parses FIT files and returns metadata like distance, duration, trackpoints, and laps.
  """

  import Squeeze.Utils, only: [cast_float: 1]

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
      distance: Map.get(session_data, "total_distance"),
      duration: round(Map.get(session_data, "total_elapsed_time")),
      moving_time: round(Map.get(session_data, "total_elapsed_time")),
      elapsed_time: round(Map.get(session_data, "total_elapsed_time")),
      start_at: start_at,
      start_at_local: Timex.shift(start_at, seconds: tz_offset_in_seconds(records)),
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
        altitude: obj["altitude"],
        cadence: obj["cadence"],
        coordinates: coordinates(obj),
        distance: obj["distance"],
        heartrate: obj["heart_rate"],
        velocity: obj["speed"],
        moving: true,
        time: Timex.diff(timestamp, start_at, :seconds)
      }
    end)
  end

  defp laps(_records) do
    []
    # tz_offset = tz_offset_in_seconds(data)
    # trackpoints = Map.get(data, "record_mesgs", [])

    # trackpoints_by_timestamp =
    #   trackpoints
    #   |> Enum.with_index()
    #   |> Enum.map(fn {tp, idx} -> {tp["timestamp"], idx} end)
    #   |> Map.new()

    # {laps, _} =
    #   data
    #   |> Map.get("lap_mesgs", [])
    #   |> Enum.map_reduce(0, fn lap, tkpt_idx ->
    #     start_time = Timex.parse!(lap["start_time"], "{ISO:Extended:Z}")
    #     end_idx = Map.get(trackpoints_by_timestamp, lap["timestamp"], length(trackpoints))

    #     {%{
    #        average_cadence: cast_float(lap["avg_cadence"]),
    #        average_speed: cast_float(lap["avg_speed"]),
    #        distance: cast_float(lap["total_distance"]),
    #        elapsed_time: round(lap["total_elapsed_time"]),
    #        start_index: tkpt_idx,
    #        end_index: end_idx,
    #        lap_index: lap["message_index"],
    #        max_speed: cast_float(lap["max_speed"]),
    #        moving_time: round(lap["total_elapsed_time"]),
    #        name: lap["event"],
    #        split: lap["message_index"] + 1,
    #        start_date: start_time |> to_naive_datetime(),
    #        start_date_local: start_time |> Timex.shift(seconds: tz_offset) |> to_naive_datetime(),
    #        total_elevation_gain: cast_float(lap["total_ascent"])
    #      }, end_idx + 1}
    #   end)

    # laps
  end

  defp tz_offset_in_seconds(records) do
    # Calculate the local timezone
    # For some reason fit epoch is offset slightly
    fit_epoch_offset = 631_065_600

    activity_msg =
      records
      |> Enum.find(&(&1.kind == "activity"))
      |> Map.get(:fields, [])
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, value)
      end)

    timestamp = Timex.parse!(activity_msg["timestamp"], "{ISO:Extended:Z}")
    local_ts = Timex.from_unix(activity_msg["local_timestamp"] + fit_epoch_offset)
    Timex.diff(local_ts, timestamp, :seconds)
  end

  # defp to_naive_datetime(datetime) do
  #   datetime
  #   |> Timex.to_naive_datetime()
  #   |> NaiveDateTime.truncate(:second)
  # end

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
end

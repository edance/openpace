defmodule Squeeze.FileParser.FitImport do
  @moduledoc """
  Parses FIT files and returns metadata like distance, duration, trackpoints, and laps.
  """

  import Squeeze.Utils, only: [cast_float: 1]

  def import_from_file(filename) do
    {:ok, result} = Squeeze.FitDecoder.call(filename)
    data = Jason.decode!(result)
    start_at = start_at(data)

    %{
      type: type(data),
      activity_type: activity_type(data),
      distance: Map.get(session_msg(data), "total_distance"),
      duration: round(Map.get(session_msg(data), "total_elapsed_time")),
      start_at: start_at,
      start_at_local: Timex.shift(start_at, seconds: tz_offset_in_seconds(data)),
      elevation_gain: session_msg(data) |> Map.get("total_ascent") |> cast_float(),
      polyline: nil, # need to make on my own
      trackpoints: trackpoints(data),
      laps: laps(data)
    }
  end

  defp session_msg(data) do
    data["session_mesgs"] |> List.first()
  end

  defp type(data) do
    case Map.get(session_msg(data), "sport") do
      "running" -> "Run"
      "cycling" -> "Bike"
      "swimming" -> "Swim"
      sport -> sport
    end
  end

  defp activity_type(data) do
    case Map.get(session_msg(data), "sport") do
      "running" -> :run
      "cycling" -> :bike
      "swimming" -> :swim
      _sport -> :other
    end
  end

  defp start_at(data) do
    start_time = Map.get(session_msg(data), "start_time")
    Timex.parse!(start_time, "{ISO:Extended:Z}")
  end

  defp trackpoints(data) do
    start_at = start_at(data)

    data
    |> Map.get("record_mesgs", [])
    |> Enum.map(fn x ->
      timestamp = Timex.parse!(x["timestamp"], "{ISO:Extended:Z}")

      %{
        altitude: x["altitude"],
        cadence: x["cadence"],
        coordinates: coordinates(x),
        distance: x["distance"],
        heartrate: x["heart_rate"],
        velocity: x["speed"],
        moving: true,
        time: Timex.diff(timestamp, start_at, :seconds)
      }
    end)
  end

  defp laps(data) do
    tz_offset = tz_offset_in_seconds(data)

    data
    |> Map.get("lap_mesgs", [])
    |> Enum.map(fn x ->
      timestamp = Timex.parse!(x["start_time"], "{ISO:Extended:Z}")

      %{
        average_cadence: cast_float(x["avg_cadence"]),
        average_speed: cast_float(x["avg_speed"]),
        distance: cast_float(x["total_distance"]),
        elapsed_time: round(x["total_elapsed_time"]),
        start_index: 0,
        end_index: 0,
        lap_index: 0,
        max_speed: cast_float(x["max_speed"]),
        moving_time: round(x["total_elapsed_time"]),
        name: x["event"],
        pace_zone: 0,
        split: x["message_index"],
        start_date: timestamp |> to_naive_datetime(),
        start_date_local: timestamp |> Timex.shift(seconds: tz_offset) |> to_naive_datetime(),
        total_elevation_gain: cast_float(x["total_ascent"])
      }
    end)
  end

  defp tz_offset_in_seconds(data) do
    # Calculate the local timezone
    # For some reason fit epoch is offset slightly
    fit_epoch_offset = 631_065_600
    activity_msg = data["activity_mesgs"] |> List.first()
    timestamp = Timex.parse!(activity_msg["timestamp"], "{ISO:Extended:Z}")
    local_ts = Timex.from_unix(activity_msg["local_timestamp"] + fit_epoch_offset)
    Timex.diff(local_ts, timestamp, :seconds)
  end

  defp to_naive_datetime(datetime) do
    datetime
    |> Timex.to_naive_datetime()
    |> NaiveDateTime.truncate(:second)
  end

  defp coordinates(record_msg) do
    if record_msg["position_long"] && record_msg["position_lat"] do
      %{
        lat: record_msg["position_lat"] / 11_930_465,
        lon: record_msg["position_long"] / 11_930_465
      }
    else
      %{}
    end
  end
end

defmodule Squeeze.FileParser.FitImport do
  @moduledoc """
  Parses FIT files and returns metadata like distance, duration, trackpoints, and laps.
  """

  import Squeeze.Utils, only: [cast_float: 1]

  def import_from_file(filename) do
    {:ok, result} = Squeeze.FitDecoder.call(filename)
    data = Jason.decode!(result)
    start_at = start_at(data)
    trackpoints = trackpoints(data)

    %{
      type: type(data),
      activity_type: activity_type(data),
      distance: Map.get(session_msg(data), "total_distance"),
      duration: round(Map.get(session_msg(data), "total_elapsed_time")),
      moving_time: round(Map.get(session_msg(data), "total_elapsed_time")),
      elapsed_time: round(Map.get(session_msg(data), "total_elapsed_time")),
      start_at: start_at,
      start_at_local: Timex.shift(start_at, seconds: tz_offset_in_seconds(data)),
      elevation_gain: session_msg(data) |> Map.get("total_ascent") |> cast_float(),
      polyline: polyline(trackpoints),
      trackpoints: trackpoints,
      laps: laps(data)
    }
  end

  defp session_msg(data) do
    data["session_mesgs"] |> List.first()
  end

  defp type(data) do
    case Map.get(session_msg(data), "sport") do
      "running" -> "Run"
      "cycling" -> "Ride"
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

  defp polyline(trackpoints) do
    trackpoints
    |> Enum.map(& &1.coordinates)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&{&1.lon, &1.lat})
    |> Polyline.encode()
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
    trackpoints = Map.get(data, "record_mesgs", [])

    trackpoints_by_timestamp =
      trackpoints
      |> Enum.with_index()
      |> Enum.map(fn {tp, idx} -> {tp["timestamp"], idx} end)
      |> Map.new()

    {laps, _} =
      data
      |> Map.get("lap_mesgs", [])
      |> Enum.map_reduce(0, fn lap, tkpt_idx ->
        start_time = Timex.parse!(lap["start_time"], "{ISO:Extended:Z}")
        end_idx = Map.get(trackpoints_by_timestamp, lap["timestamp"], length(trackpoints))

        {%{
           average_cadence: cast_float(lap["avg_cadence"]),
           average_speed: cast_float(lap["avg_speed"]),
           distance: cast_float(lap["total_distance"]),
           elapsed_time: round(lap["total_elapsed_time"]),
           start_index: tkpt_idx,
           end_index: end_idx,
           lap_index: lap["message_index"],
           max_speed: cast_float(lap["max_speed"]),
           moving_time: round(lap["total_elapsed_time"]),
           name: lap["event"],
           split: lap["message_index"] + 1,
           start_date: start_time |> to_naive_datetime(),
           start_date_local: start_time |> Timex.shift(seconds: tz_offset) |> to_naive_datetime(),
           total_elevation_gain: cast_float(lap["total_ascent"])
         }, end_idx + 1}
      end)

    laps
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
      nil
    end
  end
end

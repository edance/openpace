defmodule Squeeze.FileParser.TcxImport do
  @moduledoc """
  Parses TCX files and returns metadata like distance, duration, trackpoints, and laps.
  """

  import SweetXml
  import Squeeze.Utils, only: [sum_by: 2]

  def import_from_file(filename) do
    # I'd love to stream this file but all the tcx files have leading spaces
    {:ok, file} = File.open(filename, [:read, :compressed])
    doc = IO.read(file, :all) |> String.trim_leading()
    File.close(file)

    laps = laps(doc)
    trackpoints = Enum.flat_map(laps, fn x -> x.trackpoints end)

    %{
      type: type(doc),
      activity_type: activity_type(doc),
      elapsed_time: laps |> sum_by(:elapsed_time),
      moving_time: laps |> sum_by(:moving_time),
      distance: laps |> sum_by(:distance),
      start_at: laps |> List.first() |> Map.get(:start_date),
      start_at_local: laps |> List.first() |> Map.get(:start_date_local),
      elevation_gain: 0,
      polyline: polyline(trackpoints),
      trackpoints: trackpoints,
      laps: laps,
      external_id: external_id(doc)
    }
  end

  defp polyline(trackpoints) do
    trackpoints
    |> Enum.map(&(&1.coordinates))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&({&1.lon, &1.lat}))
    |> Polyline.encode()
  end

  defp external_id(doc) do
    doc
    |> xpath(~x"//Id/text()"s)
    |> Timex.parse!("{ISO:Extended:Z}")
    |> Timex.to_unix()
  end

  defp type(doc) do
    xpath(doc, ~x"//Activity/@Sport"s)
  end

  defp activity_type(doc) do
    xpath(doc, ~x"//Activity/@Sport"s)
  end

  defp laps(doc) do
    doc
    |> laps_data()
    |> Enum.with_index()
    |> Enum.map(fn({lap, idx}) ->
      trackpoint_count = length(lap.trackpoints)

      %{
        average_cadence: sum_by(lap.trackpoints, :cadence) / trackpoint_count,
        average_speed: lap.distance / lap.elapsed_time,
        distance: lap.distance,
        elapsed_time: lap.elapsed_time,
        lap_index: idx,
        max_speed: lap.max_speed,
        moving_time: lap.elapsed_time, # TODO
        name: "Lap",
        split: idx + 1,
        start_date: start_date(lap.start_time),
        start_date_local: start_date_local(lap.start_time),
        total_elevation_gain: 0 # TODO
      }
    end)
  end

  defp start_date(time_str) do
    time_str
    |> Timex.parse!("{ISO:Extended:Z}")
    |> Timex.to_naive_datetime()
  end

  defp start_date_local(time_str) do
    time_str
    |> Timex.parse!("{ISO:Extended:Z}")
    |> Timex.format!("%FT%TZ", :strftime)
    |> Timex.parse!("{ISO:Extended:Z}")
    |> Timex.to_naive_datetime()
  end

  defp laps_data(doc) do
    doc |> xpath(
      ~x"//Lap"l,
      distance: ~x"./DistanceMeters/text()"f,
      elapsed_time: ~x"./TotalTimeSeconds/text()"f,
      start_time: ~x"./@StartTime"s,
      max_speed: ~x"./MaximumSpeed/text()"F,
      calories: ~x"./Calories/text()"I,
      average_heartrate: ~x"./AverageHeartRateBpm/Value/text()"I,
      max_heartrate: ~x"./MaximumHeartRateBpm/Value/text()"I,
      trackpoints: [
        ~x"//Trackpoint"l,
        coordinates: [
          ~x"./Position",
          lat: ~x"./LatitudeDegrees/text()"f,
          lon: ~x"./LongitudeDegrees/text()"f
        ],
        altitude: ~x"./AltitudeMeters/text()"f,
        cadence: ~x"./Extensions/ns3:TPX/ns3:RunCadence/text()"I,
        distance: ~x"./DistanceMeters/text()"f,
        heartrate: ~x"./HeartRateBpm/Value/text()"I,
        time: ~x"./Time/text()"s,
        velocity: ~x"./Extensions/ns3:TPX/ns3:Speed/text()"F
      ]
    )
  end
end

defmodule Squeeze.Strava.StreamSetConverterTest do
  use Squeeze.DataCase

  alias Squeeze.Strava.StreamSetConverter
  alias Strava.StreamSet

  describe "convert_stream_set_to_trackpoints/1" do
    setup [:build_stream_set]

    test "converts stream set to trackpoints", %{stream_set: stream_set} do
      trackpoints = StreamSetConverter.convert_stream_set_to_trackpoints(stream_set)

      assert trackpoints == [
               %{
                 altitude: 77.2,
                 cadence: 58,
                 distance: 0.0,
                 grade_smooth: 3.3,
                 heartrate: 110,
                 moving: false,
                 temp: 26,
                 time: 0,
                 velocity: 0.0,
                 watts: 119,
                 coordinates: %{lat: 37.7749, lon: -122.4194}
               }
             ]
    end

    test "without latlng", %{stream_set: stream_set} do
      stream_set = Map.delete(stream_set, :latlng)

      trackpoints = StreamSetConverter.convert_stream_set_to_trackpoints(stream_set)

      assert trackpoints == [
               %{
                 altitude: 77.2,
                 cadence: 58,
                 distance: 0.0,
                 grade_smooth: 3.3,
                 heartrate: 110,
                 moving: false,
                 temp: 26,
                 time: 0,
                 velocity: 0.0,
                 watts: 119
               }
             ]
    end
  end

  defp build_stream_set(_) do
    stream_set = %StreamSet{
      altitude: %{data: [77.2]},
      cadence: %{data: [58]},
      distance: %{data: [0.0]},
      grade_smooth: %{data: [3.3]},
      heartrate: %{data: [110]},
      latlng: %{data: [[37.7749, -122.4194]]},
      moving: %{data: [false]},
      temp: %{data: [26]},
      time: %{data: [0]},
      velocity_smooth: %{data: [0]},
      watts: %{data: [119]}
    }

    {:ok, stream_set: stream_set}
  end
end

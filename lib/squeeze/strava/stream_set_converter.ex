defmodule Squeeze.Strava.StreamSetConverter do
  @moduledoc """
  Convert strava stream sets into trackpoints
  """

  alias Strava.StreamSet

  @streams ~w(
    altitude
    cadence
    distance
    grade_smooth
    heartrate
    latlng
    moving
    temp
    time
    velocity_smooth
    watts
  )a

  def convert_stream_set_to_trackpoints(%StreamSet{} = stream_set) do
    streams()
    |> Enum.map(&map_stream_data(stream_set, &1))
    |> Enum.reject(&is_nil/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn(result) -> Enum.reduce(result, %{}, &Map.merge(&1, &2)) end)
    |> Enum.map(&map_to_trackpoint/1)
  end

  def streams do
    @streams
  end

  def map_stream_data(stream_set, field) do
    case Map.get(stream_set, field) do
      nil -> nil
      stream -> Enum.map(stream.data, &Map.put(%{}, field, &1))
    end
  end

  # %{
  #   altitude: 49.0,
  #   cadence: 57,
  #   heartrate: 88,
  #   latlng: [37.778892, -122.43865],
  #   moving: false,
  #   time: 0,
  #   velocity_smooth: 0.0
  # }
  def map_to_trackpoint(%{latlng: latlng} = trackpoint) when length(latlng) == 2 do
    coordinates = %{lat: List.first(latlng), lon: List.last(latlng)}
    trackpoint
    |> Map.delete(:latlng)
    |> map_to_trackpoint()
    |> Map.merge(%{coordinates: coordinates})
  end

  def map_to_trackpoint(trackpoint) do
    %{
      altitude: trackpoint[:altitude],
      cadence: trackpoint[:cadence],
      distance: trackpoint[:distance],
      heartrate: trackpoint[:heartrate],
      moving: trackpoint[:moving],
      time: trackpoint[:time],
      velocity: velocity(trackpoint)
    }
  end

  defp velocity(%{velocity_smooth: 0}), do: 0.0
  defp velocity(%{velocity_smooth: velocity}), do: velocity
end

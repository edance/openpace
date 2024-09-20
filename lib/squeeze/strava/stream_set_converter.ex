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
    |> Enum.map(fn result -> Enum.reduce(result, %{}, &Map.merge(&1, &2)) end)
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
  #   altitude: 77.2, 
  #   cadence: 58,
  #   distance: 0.0,
  #   grade_smooth: 3.3,
  #   heartrate: 110,
  #   moving: false,
  #   temp: 26,
  #   time: 0,
  #   velocity_smooth: 0.0,
  #   watts: 119
  # }
  def map_to_trackpoint(%{latlng: latlng} = trackpoint) when length(latlng) == 2 do
    coordinates = %{lat: List.first(latlng), lon: List.last(latlng)}
    velocity = velocity(trackpoint)

    trackpoint
    |> Map.delete(:latlng)
    |> Map.delete(:velocity_smooth)
    |> Map.merge(%{coordinates: coordinates, velocity: velocity})
  end

  defp velocity(%{velocity_smooth: 0}), do: 0.0
  defp velocity(%{velocity_smooth: velocity}), do: velocity
end

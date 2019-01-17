defmodule Squeeze.Split do
  @moduledoc """
  Calculates splits from a stream_set
  """

  alias Squeeze.Accounts.User
  alias Squeeze.Distances

  def calculate_splits(%User{} = user, stream_set) do
    distance_stream = distance_stream(user, stream_data(stream_set.distance))
    time_stream = stream_data(stream_set.time)

    total_distance = List.last(distance_stream)
    increments = split_increments(total_distance)
    splits = increments
    |> Enum.map(&build(&1, distance_stream, time_stream))

    splits
    |> Enum.with_index()
    |> Enum.map(fn({v, i}) ->
      if i == 0 do
        Map.put(v, :pace, v.total_time)
      else
        prev = Enum.at(splits, i - 1)
        pace = v.total_time - prev.total_time
        Map.put(v, :pace, pace)
      end
    end)
  end

  defp build(distance, distance_stream, time_stream) do
    %{
      distance: distance,
      total_time: time_at_distance(distance, distance_stream, time_stream)
    }
  end

  defp split_increments(nil), do: []
  defp split_increments(distance) when distance <= 0, do: []
  defp split_increments(total_distance) do
    trunc_distance = trunc(total_distance)
    Enum.to_list(1..trunc_distance)
  end

  defp distance_stream(user, data) do
    data
    |> Enum.map(&Distances.to_float(&1, imperial: user.user_prefs.imperial))
  end

  defp stream_data(stream) do
    case stream do
      nil -> []
      stream -> stream.data
    end
  end

  defp time_at_distance(distance, distance_stream, time_stream) do
    {_, idx} = distance_stream
    |> Enum.with_index()
    |> Enum.filter(fn({dist, _}) -> dist >= distance end)
    |> List.first()
    Enum.at(time_stream, idx)
  end
end

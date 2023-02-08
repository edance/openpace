defmodule Squeeze.Splits do
  @moduledoc """
  This module calculates the splits for a set of trackpoints.
  """

  alias Squeeze.Duration

  @doc """
  TBD
  """
  def calculate_splits(trackpoints, opts \\ [split_distance: 1000]) do
    split_distance = Keyword.get(opts, :split_distance, 1000)

    [tp1 | rest] = trackpoints

    acc = %{last_tp: tp1, stopped_time: 0, splits: []}
    do_work(rest, acc, split_distance)
  end

  def do_work([], acc, split_distance) do
    # split = %{
    #   split: curr_split,
    #   distance: split,
    #   time: split_time,
    #   moving_time: split_time - acc.stopped_time
    # }

    # splits = acc.splits ++ [split]

    acc
  end

  def do_work(rest, acc, split_distance) do
    last_tp = acc.last_tp
    [tp | rest] = rest

    last_split = trunc(last_tp.distance / split_distance)
    curr_split = trunc(tp.distance / split_distance)

    acc = if !tp.moving && !last_tp.moving do
      stopped_time = acc.stopped_time + (tp.time - last_tp.time)
      Map.merge(acc, %{stopped_time: stopped_time})
    else
      acc
    end

    if last_split == curr_split do
      do_work(rest, Map.merge(acc, %{last_tp: tp}), split_distance)
    else
      distance = tp.distance - last_tp.distance
      split = curr_split * split_distance
      percentage = (split - last_tp.distance) / distance

      total_time = tp.time - last_tp.time
      additional_time = percentage * total_time

      split_time = round(last_tp.time + additional_time)

      split = %{
        split: curr_split,
        distance: split,
        time: split_time,
        moving_time: split_time - acc.stopped_time
      }

      splits = acc.splits ++ [split]
      acc = Map.merge(acc, %{last_tp: tp, stopped_time: 0, splits: splits})

      do_work(rest, acc, split_distance)
    end
  end

  defp stopped_time(tp1, tp2) do
    if not_moving?(tp1, tp2) do
      tp2.time - tp1.time
    else
      0
    end
  end

  defp not_moving?(tp1, tp2) do
    !tp1.moving && !tp2.moving
  end
end

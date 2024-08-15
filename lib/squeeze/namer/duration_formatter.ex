defmodule Squeeze.Namer.DurationFormatter do
  @moduledoc """
  This module formats the duration
  """

  def format(%{distance: distance}) when distance > 0, do: nil

  def format(%{moving_time: t}) do
    minutes = trunc(rem(t, 60 * 60) / 60)
    hours = trunc(t / (60 * 60))

    if hours > 0 do
      "#{hours}h #{pad_num(minutes)}m"
    else
      "#{minutes}min"
    end
  end

  defp pad_num(x) when x < 10, do: "0#{x}"
  defp pad_num(x), do: "#{x}"
end

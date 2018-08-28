defmodule Squeeze.Duration do
  @behaviour Ecto.Type

  @moduledoc """
  This module defines an ecto type for a duration. This is stored as an integer
  in the database and converted to a duration. A duration has hours, minutes,
  and seconds. Additionally there is a total which is the total number of
  seconds.
  """

  alias Ecto.Type
  alias Timex.Duration

  def cast(%{"hours" => hours, "minutes" => minutes, "seconds" => seconds}) do
    hours = parse_int(hours)
    minutes = parse_int(minutes)
    seconds = parse_int(seconds)
    cast(hours * 3600 + minutes * 60 + seconds)
  end

  def cast(number) do
    Type.cast(:integer, number)
  end

  def dump(number) do
    Type.dump(:integer, number)
  end

  def load(number) do
    {hours, minutes, seconds, _} =
      number
      |> Duration.from_seconds()
      |> Duration.to_clock()

    {:ok, %{hours: hours, minutes: minutes, seconds: seconds, total: number}}
  end

  def type do
    Type.type(:integer)
  end

  defp parse_int(str) do
    case Integer.parse(str) do
      {num, _} -> num
      :error -> 0
    end
  end
end

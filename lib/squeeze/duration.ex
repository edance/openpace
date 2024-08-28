defmodule Squeeze.Duration do
  @moduledoc """
  This duration module parses and formats strings for a time duration in hours,
  minutes, and seconds.
  """
  @behaviour Ecto.Type

  @match ~r/^(?<hour>\d{1,2}):(?<min>\d{1,2}):?(?<sec>\d{0,2})$/

  alias Squeeze.Utils

  def cast(str) when is_binary(str) do
    case Regex.named_captures(@match, str) do
      nil ->
        parse_integer(str)

      %{"hour" => hour_str, "min" => min_str, "sec" => sec_str} ->
        with {:ok, hours} <- parse_integer(hour_str),
             {:ok, minutes} <- parse_integer(min_str),
             {:ok, seconds} <- parse_integer(sec_str),
             do: cast_to_secs(hours, minutes, seconds)
    end
  end

  def cast(map) when is_map(map) do
    # Convert string or atom map to atom map
    map = Utils.key_to_atom(map)

    with {:ok, hours} <- Map.get(map, :hour, nil) |> parse_integer(),
         {:ok, minutes} <- Map.get(map, :min, nil) |> parse_integer(),
         {:ok, seconds} <- Map.get(map, :sec, nil) |> parse_integer() do
      number = 60 * 60 * (hours || 0) + 60 * (minutes || 0) + (seconds || 0)
      cast(number)
    end
  end

  def cast(number) do
    Ecto.Type.cast(:integer, number)
  end

  def format(nil), do: nil
  def format(t) when is_float(t), do: format(trunc(t))

  def format(t) do
    seconds = rem(t, 60)
    minutes = trunc(rem(t, 60 * 60) / 60)
    hours = trunc(t / (60 * 60))

    if hours > 0 do
      "#{hours}:#{pad_num(minutes)}:#{pad_num(seconds)}"
    else
      "#{minutes}:#{pad_num(seconds)}"
    end
  end

  def dump(number) do
    Ecto.Type.dump(:integer, number)
  end

  def load(number) do
    Ecto.Type.load(:integer, number)
  end

  def type do
    Ecto.Type.type(:integer)
  end

  def embed_as(_), do: :self

  def equal?(left, right), do: left == right

  def to_seconds(time) do
    Map.get(time, :hours, 0) * 3600 + Map.get(time, :minutes, 0) * 60 + Map.get(time, :seconds)
  end

  defp parse_integer(""), do: {:ok, nil}
  defp parse_integer(nil), do: {:ok, nil}

  defp parse_integer(str) when is_binary(str) do
    case Integer.parse(str) do
      {value, _} -> {:ok, value}
      :error -> :error
    end
  end

  defp cast_to_secs(minutes, seconds, nil), do: {:ok, minutes * 60 + seconds}

  defp cast_to_secs(hours, minutes, seconds) do
    {:ok, hours * 3600 + minutes * 60 + seconds}
  end

  defp pad_num(x) when x < 10, do: "0#{x}"
  defp pad_num(x), do: "#{x}"
end

defmodule Squeeze.Duration do
  @behaviour Ecto.Type

  def cast(%{"hours" => hours, "minutes" => minutes, "seconds" => seconds}) do
    {hours, _} = Integer.parse(hours)
    {minutes, _} = Integer.parse(minutes)
    {seconds, _} = Integer.parse(seconds)
    cast(hours * 3600 + minutes * 60 + seconds)
  end

  def cast(number) do
    Ecto.Type.cast(:integer, number)
  end

  def dump(number) do
    Ecto.Type.dump(:integer, number)
  end

  def load(number) do
    {hours, minutes, seconds, _} =
      Timex.Duration.from_seconds(number)
      |> Timex.Duration.to_clock()

    {:ok, %{hours: hours, minutes: minutes, seconds: seconds}}
  end

  def type() do
    Ecto.Type.type(:integer)
  end
end

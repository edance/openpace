defmodule SqueezeWeb.FormatHelpers do
  use Phoenix.HTML

  import Phoenix.HTML

  alias Timex.Duration

  @doc """
  Formats a duration like a stopwatch

  ## Examples

    iex> format_duration(duration)
    "3:00:00"
  """
  def format_duration(%{total: seconds}) do
    duration = Duration.from_seconds(seconds)
    Duration.to_time!(duration)
    |> Timex.format!(format(duration), :strftime)
  end

  def format_distance(distance) do
    raw("Marathon")
  end

  defp format(duration) do
    case Duration.to_hours(duration) do
      x when x < 1 -> "%-M:%S"
      _ -> "%-H:%M:%S"
    end
  end
end

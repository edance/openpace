defmodule Squeeze.Namer.RelativeTimeFormatter do
  @moduledoc """
  This module converts an activity into Morning, Afternoon, Evening, and Night
  """

  def format(%{start_date_local: timestamp}) when not is_nil(timestamp) do
    case timestamp.hour do
      x when x >= 5 and x < 12 -> "Morning" # 5am until 12 noon
      x when x >= 12 and x < 17 -> "Afternoon" # noon until 5pm
      x when x >= 17 and x < 21 -> "Evening" # 5pm until 9pm
      _ -> "Night" # After 9pm
    end
  end

  def format(_), do: nil
end

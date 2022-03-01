defmodule Squeeze.Namer.NameGenerator do
  @moduledoc """
  This module creates names for a user and activity.
  """

  alias Squeeze.Namer.ActivityTypeFormatter
  alias Squeeze.Namer.DistanceFormatter
  alias Squeeze.Namer.DurationFormatter
  alias Squeeze.Namer.EmojiFormatter
  alias Squeeze.Namer.RelativeTimeFormatter

  def generate_name(%{user_prefs: %{emoji: emoji, gender: gender, imperial: imperial}}, activity) do
    parts = [
      EmojiFormatter.format(activity, emoji: emoji, gender: gender),
      DistanceFormatter.format(activity, imperial: imperial),
      DurationFormatter.format(activity),
      RelativeTimeFormatter.format(activity),
      ActivityTypeFormatter.format(activity.type)
    ]

    parts
    |> Enum.reject(&is_blank/1)
    |> Enum.join(" ")
  end

  defp is_blank(str), do: is_nil(str) || String.trim(str) == ""
end

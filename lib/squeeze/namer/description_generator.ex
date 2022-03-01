defmodule Squeeze.Namer.DescriptionGenerator do
  @moduledoc """
  This module converts an activity into Morning, Afternoon, Evening, and Night
  """

  @branding_text "Renamed with openpace.co/namer"

  def generate_description(%{user_prefs: %{branding: true}}, %{description: description}) do
    [
      stripped_description(description),
      @branding_text
    ]
    |> Enum.reject(&is_blank/1)
    |> Enum.join(" - ")
  end

  def generate_description(_, %{description: description}), do: description

  def generate_description(_, _), do: nil

  defp is_blank(str), do: is_nil(str) || String.trim(str) == ""

  defp stripped_description(description) when is_nil(description), do: ""

  defp stripped_description(description) do
    String.replace(description, @branding_text, "")
  end
end

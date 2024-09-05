defmodule Squeeze.Colors do
  @moduledoc """
  Color codes for different activities and gradients.
  """

  def blue, do: "#5e72e4"
  def indigo, do: "#5603ad"
  def purple, do: "#8965e0"
  def pink, do: "#f3a4b5"
  def red, do: "#f5365c"
  def orange, do: "#fb6340"
  def yellow, do: "#ffd600"
  def green, do: "#2dce89"
  def teal, do: "#11cdef"
  def cyan, do: "#2bffc6"
  def waves, do: "#2e3148"

  def activity_color(type) do
    cond do
      String.contains?(type, "Run") -> red()
      String.contains?(type, "Hike") -> orange()
      String.contains?(type, "Ride") -> blue()
      String.contains?(type, "Swim") -> green()
      true -> yellow()
    end
  end
end

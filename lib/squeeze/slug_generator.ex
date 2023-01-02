defmodule Squeeze.SlugGenerator do
  @moduledoc """
  Generates unique slugs for object urls
  """

  @doc """
  Generates a six character long alphanumeric string

  ## Examples

  iex> gen_slug()
  "hrz9f6"

  """
  def gen_slug(length \\ 6) do
    for _ <- 1..length, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyz')>>
  end
end

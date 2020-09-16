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
  def gen_slug do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
    |> String.downcase()
  end
end

defmodule Squeeze.Stringable do
  @moduledoc """
  This ecto type allows for both integers and strings. This is used when we want
  to store segment_id (an external identifier) as a string and not an integer.
  """
  @behaviour Ecto.Type

  def cast(s) when is_binary(s), do: {:ok, s}

  def cast(val) do
    if String.Chars.impl_for(val) do
      {:ok, to_string(val)}
    else
      {:error, "cannot convert to string"}
    end
  end

  def dump(str) do
    Ecto.Type.dump(:string, str)
  end

  def load(str) do
    Ecto.Type.load(:string, str)
  end

  def type do
    Ecto.Type.type(:string)
  end

  def embed_as(_), do: :self

  def equal?(left, right), do: left == right
end

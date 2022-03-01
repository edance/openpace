defmodule SqueezeWeb.Settings.NamerCardComponent do
  use SqueezeWeb, :live_component

  def gender_opts do
    GenderEnum.__enum_map__()
    |> Enum.map(fn ({k, _}) -> {format_option(k), k} end)
  end

  defp format_option(opt) do
    opt
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end

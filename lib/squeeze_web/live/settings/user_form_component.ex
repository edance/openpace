defmodule SqueezeWeb.Settings.UserFormComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.Accounts.UserPrefs

  defp time_zones do
    Tzdata.zone_list()
    |> Enum.map(fn x ->
      {String.replace(x, "_", " "), x}
    end)
  end

  defp gender_opts do
    Ecto.Enum.mappings(UserPrefs, :gender)
    |> Enum.map(fn {k, _} -> {format_option(k), k} end)
  end

  defp format_option(opt) do
    opt
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end

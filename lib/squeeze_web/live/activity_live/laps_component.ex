defmodule SqueezeWeb.ActivityLive.LapsComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  def show_cadence?(%{activity: %{laps: laps}}) do
    case List.first(laps) do
      nil ->
        false

      lap ->
        cadence = Map.get(lap, :average_cadence)
        !is_nil(cadence) && cadence > 0
    end
  end

  def show_cadence?(_), do: false
end

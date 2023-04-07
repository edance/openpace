defmodule SqueezeWeb.Races.TrainingCardComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:activity_map, activity_map(assigns))
     |> assign(:weeks, weeks(assigns))}
  end

  defp activity_map(%{activities: activities}) do
    activities
    |> Enum.reduce(%{}, fn x, acc ->
      date = x.start_at_local |> Timex.to_date()
      list = Map.get(acc, date, [])
      Map.put(acc, date, [x | list])
    end)
  end

  defp weeks(%{race_goal: race_goal}) do
    end_date = race_goal.race_date
    start_date = Timex.shift(end_date, weeks: -18)
    range = Date.range(start_date, end_date)

    range
    |> Enum.with_index()
    |> Enum.group_by(fn {_, idx} -> div(idx, 7) end, fn {v, _} -> v end)
  end
end

defmodule SqueezeWeb.EventController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Event
  alias Squeeze.Distances

  require IEx
  require IO

  def new(conn, params) do
    current_week = String.to_integer(params["current_week"])
    date = parse_date(params["date"])
    start_date = Date.add(date, 7 * current_week)
    changesets = start_date
    |> Date.range(Date.add(start_date, 6))
    |> Enum.map(fn(x) -> Dashboard.change_event(%Event{date: x}) end)
    render(conn, "new.html", changesets: changesets)
  end

  def create(conn, %{"events" => events}) do
    user = conn.assigns.current_user
    events
    |> Enum.map(fn({_, v}) -> v end)
    |> Enum.map(&format_name(&1))
    |> Enum.map(&add_distance_to_event(&1))
    |> Enum.each(&Dashboard.create_event(user, &1))
    conn
    |> redirect(to: dashboard_path(conn, :index))
  end

  defp parse_date(date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> Timex.today
    end
  end

  defp format_name(%{"name" => ""} = event), do: %{event | "name" => "Rest"}
  defp format_name(event), do: event

  defp add_distance_to_event(event) do
    Map.merge(event, %{"distance" => parse_distance(event["name"])})
  end

  defp parse_distance(str) do
    case Distances.parse(str) do
      {:ok, distance} -> distance
      {:error} -> 0
    end
  end
end

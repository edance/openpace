defmodule SqueezeWeb.PlanController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller module to help create training plans
  """

  @steps ~w(weeks start)

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Event
  alias Squeeze.Distances

  plug :validate_step when action in [:step, :update]

  def step(conn, %{"step" => step}) do
    render(conn, "step.html", step: step)
  end

  def update(conn, %{"step" => step, "weeks" => weeks}) do
    next_step = next_step(step)
    conn
    |> put_session(:weeks, String.to_integer(weeks))
    |> redirect(to: plan_path(conn, :step, next_step))
  end

  def update(conn, %{"start_at" => start_at}) do
    conn
    |> put_session(:start_at, parse_date(start_at))
    |> redirect(to: plan_path(conn, :new, 1))
  end

  def new(conn, %{"week" => week}) do
    current_week = String.to_integer(week) - 1
    date = get_session(conn, :start_at)
    start_date = Date.add(date, 7 * current_week)
    changesets = start_date
    |> Date.range(Date.add(start_date, 6))
    |> Enum.map(fn(x) -> Dashboard.change_event(%Event{date: x}) end)

    render(conn, "new.html", changesets: changesets, week: week)
  end

  def create(conn, %{"events" => events, "week" => week}) do
    user = conn.assigns.current_user
    current_week = String.to_integer(week)
    events
    |> Enum.map(fn({_, v}) -> v end)
    |> Enum.map(&format_name(&1))
    |> Enum.map(&add_distance_to_event(&1))
    |> Enum.each(&Dashboard.create_event(user, &1))
    if current_week < get_session(conn, :weeks) do
      redirect(conn, to: plan_path(conn, :new, current_week + 1))
    else
      redirect(conn, to: dashboard_path(conn, :index))
    end
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

  defp next_step(step) do
    idx = Enum.find_index(@steps, fn(x) -> x == step end) + 1
    Enum.at(@steps, idx)
  end

  defp validate_step(conn, _) do
    %{"step" => step} = conn.params
    case Enum.member?(@steps, step) do
      true -> put_session(conn, :current_step, step)
      false ->
        conn
        |> put_status(:not_found)
        |> put_view(SqueezeWeb.ErrorView)
        |> render("404.html")
        |> halt()
    end
  end
end

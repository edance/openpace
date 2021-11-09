defmodule SqueezeWeb.CalendarController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts.User
  alias Squeeze.Calendar
  alias Squeeze.Dashboard
  alias Squeeze.TimeHelper

  @types ~w(month day)

  plug :validate_type when action in [:show]

  def index(conn, _) do
    redirect(conn, to: Routes.calendar_path(conn, :show, "month"))
  end

  def show(conn, %{"type" => type} = params) do
    user = conn.assigns.current_user
    date = parse_date(user, params["date"])
    dates = Calendar.visible_dates(date, type)
    conn
    |> assign(:date, date)
    |> assign(:dates, dates)
    |> assign(:activities_by_date, activities_by_date(user, dates))
    |> render("#{type}.html")
  end

  def activities_by_date(user, dates) do
    user
    |> Dashboard.list_activities(dates)
    |> Enum.reduce(%{}, fn(x, acc) ->
      date = x.start_at_local |> Timex.to_date()
      list = Map.get(acc, date, [])
      Map.put(acc, date, [x | list])
    end)
  end

  defp parse_date(%User{} = user, nil), do: TimeHelper.today(user)
  defp parse_date(%User{} = user, date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> parse_date(user, nil)
    end
  end

  defp validate_type(conn, _) do
    %{"type" => type} = conn.params
    case Enum.member?(@types, type) do
      true -> conn
      false ->
        conn
        |> put_status(:not_found)
        |> put_view(SqueezeWeb.ErrorView)
        |> render("404.html")
        |> halt()
    end
  end
end

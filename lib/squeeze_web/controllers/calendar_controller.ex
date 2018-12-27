defmodule SqueezeWeb.CalendarController do
  use SqueezeWeb, :controller

  alias Plug.Conn
  alias Squeeze.Accounts.User
  alias Squeeze.Calendar
  alias Squeeze.Dashboard
  alias Squeeze.TimeHelper

  def index(conn, _) do
    [ua | _] = Conn.get_req_header(conn, "user-agent")
    case Browser.mobile?(ua) do
      true -> redirect(conn, to: calendar_path(conn, :short))
      _ -> redirect(conn, to: calendar_path(conn, :month))
    end
  end

  def short(conn, params) do
    user = conn.assigns.current_user
    date = parse_date(user, params["date"])
    dates = Calendar.visible_dates(date, "short")
    conn
    |> assign(:date, date)
    |> assign(:dates, dates)
    |> assign(:activities, Dashboard.list_activities(user, dates))
    |> render("short.html")
  end

  def month(conn, params) do
    user = conn.assigns.current_user
    date = parse_date(user, params["date"])
    dates = Calendar.visible_dates(date, "month")
    conn
    |> assign(:date, date)
    |> assign(:dates, dates)
    |> assign(:activities, Dashboard.list_activities(user, dates))
    |> render("month.html")
  end

  defp parse_date(%User{} = user, nil), do: TimeHelper.today(user)
  defp parse_date(%User{} = user, date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> parse_date(user, nil)
    end
  end
end

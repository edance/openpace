defmodule SqueezeWeb.CalendarController do
  use SqueezeWeb, :controller

  alias Squeeze.Calendar
  alias Squeeze.Dashboard

  require IEx

  def index(conn, params) do
    [ua | _] = Plug.Conn.get_req_header(conn, "user-agent")
    case Browser.mobile?(ua) do
      true -> redirect(conn, to: calendar_path(conn, :short))
      _ -> redirect(conn, to: calendar_path(conn, :month))
    end
  end

  def short(conn, params) do
    user = conn.assigns.current_user
    date = parse_date(params["date"])
    dates = Calendar.visible_dates(date, "short")
    conn
    |> assign(:date, date)
    |> assign(:dates, dates)
    |> assign(:events, Dashboard.list_events(user, dates))
    |> render("short.html")
  end

  def month(conn, params) do
    user = conn.assigns.current_user
    date = parse_date(params["date"])
    dates = Calendar.visible_dates(date, "month")
    conn
    |> assign(:date, date)
    |> assign(:dates, dates)
    |> assign(:events, Dashboard.list_events(user, dates))
    |> render("month.html")
  end

  defp parse_date(nil) do
    Timex.today
  end

  defp parse_date(date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> Timex.today
    end
  end
end

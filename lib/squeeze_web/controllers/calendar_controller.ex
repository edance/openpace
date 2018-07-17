defmodule SqueezeWeb.CalendarController do
  use SqueezeWeb, :controller

  alias Squeeze.Calendar
  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Event

  def index(conn, params) do
    user = conn.assigns.current_user
    date = parse_date(params["date"])
    dates = Calendar.visible_dates(date)
    conn
    |> assign(:date, date)
    |> assign(:dates, dates)
    |> assign(:events, Dashboard.list_events(user, dates))
    |> render("index.html")
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

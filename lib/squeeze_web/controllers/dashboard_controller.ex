defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def index(conn, params) do
    user = conn.assigns.current_user
    conn
    |> assign(:date, parse_date(params["date"]))
    |> assign(:activities, Dashboard.get_todays_activities(user))
    |> render("index.html")
  end

  def parse_date(nil) do
    Timex.today
  end

  def parse_date(date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> Timex.today
    end
  end
end

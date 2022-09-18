defmodule SqueezeWeb.Api.ActivityController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Dashboard

  action_fallback SqueezeWeb.Api.FallbackController

  def index(conn, %{"start_date" => start_date, "end_date" => end_date}) do
    user = conn.assigns.current_user
    with {:ok, start_date} <- parse_date(start_date),
         {:ok, end_date} <- parse_date(end_date) do
      range = Date.range(start_date, end_date)
      activities = Dashboard.list_activities(user, range)
      render(conn, "activities.json", %{activities: activities})
    end
  end

  defp parse_date(date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> {:ok, Timex.to_date(date)}
      err -> err
    end
  end
end

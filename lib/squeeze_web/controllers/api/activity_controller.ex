defmodule SqueezeWeb.Api.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.TimeHelper

  action_fallback SqueezeWeb.Api.FallbackController

  def index(conn, %{"start_date" => start_date, "end_date" => end_date}) do
    user = conn.assigns.current_user
    with {:ok, start_date} <- parse_date(start_date),
         {:ok, end_date} <- parse_date(end_date) do
      start_at = TimeHelper.beginning_of_day(user, start_date)
      end_at = TimeHelper.end_of_day(user, end_date)
      activities = Dashboard.list_activities(user, start_at, end_at)
      render(conn, "activities.json", %{activities: activities})
    end
  end

  defp parse_date(date) do
    Timex.parse(date, "{YYYY}-{0M}-{0D}")
  end
end

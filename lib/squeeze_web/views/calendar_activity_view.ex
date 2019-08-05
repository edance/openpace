defmodule SqueezeWeb.CalendarActivityView do
  use SqueezeWeb, :view

  alias Squeeze.TimeHelper

  def on_date?(user, %NaiveDateTime{} = datetime, activity) do
    on_date?(user, NaiveDateTime.to_date(datetime), activity)
  end
  def on_date?(user, date, activity) do
    activity.planned_date == date ||
      TimeHelper.to_date(user, activity.start_at)  == date
  end

  def activity_color(%{status: :pending}), do: "info"
  def activity_color(%{status: :complete}), do: "success"
  def activity_color(%{status: :incomplete}), do: "danger"
  def activity_color(%{status: :partial}), do: "warning"

  def activity_icon(activity) do
    cond do
      String.contains?(activity.type, "Run") ->
        "ic:baseline-directions-run"
      String.contains?(activity.type, "Ride") ->
        "ic:baseline-directions-bike"
      String.contains?(activity.type, "Swim") ->
        "map:swimming"
      true -> "map:gym"
    end
  end

  def ordered_activities(%{activities: activities, current_user: user, date: date}) do
    activities
    |> Enum.filter(&(on_date?(user, date, &1)))
    |> Enum.sort_by(&(&1.start_at))
  end

  def formatted_start_at(%{activity: activity, current_user: user}) do
    timezone = user.user_prefs.timezone

    activity.start_at
    |> Timex.to_datetime(timezone)
    |> Timex.format!("%-I:%M %p ", :strftime)
  end
end

defmodule Squeeze.ActivityMatcher do
  @moduledoc """
  Matches the users closest activity
  """

  alias Squeeze.Accounts.{User}
  alias Squeeze.Dashboard

  def get_closest_activity(%User{} = user, %{} = activity) do
    date = Timex.to_date(activity.start_at_local)
    user
    |> Dashboard.get_activities_by_date(date)
    |> Enum.filter(&(&1.type == activity.type))
    |> Enum.sort(fn(a, b) -> match_score(a, activity) > match_score(b, activity) end)
    |> List.first()
  end

  defp match_score(planned_activity, activity) do
    pending_score(planned_activity) +
      external_score(planned_activity, activity) +
      distance_match(planned_activity, activity) +
      duration_match(planned_activity, activity)
  end

  defp external_score(planned_activity, activity) do
    if planned_activity.external_id == activity.external_id do
      100
    else
      0
    end
  end

  defp pending_score(%{status: status}) when status == :pending, do: 1
  defp pending_score(_), do: 0

  defp distance_match(%{planned_distance: planned_distance}, %{distance: distance}) do
    percent_match(planned_distance, distance)
  end

  defp duration_match(%{planned_duration: planned_duration}, %{duration: duration}) do
    percent_match(planned_duration, duration)
  end

  defp percent_match(a, b)
  when is_number(a) and a > 0 and is_number(b) and b > 0 do
    Enum.max([0, 1.0 - abs(a - b) / a])
  end
  defp percent_match(_, _), do: 0
end

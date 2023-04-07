defmodule Squeeze.ActivityMatcher do
  @moduledoc """
  This module matches new activities to existing activities.
  """

  alias Squeeze.Accounts.{User}
  alias Squeeze.Activities

  @doc """
  Gets the closest activity for a user given an activity.

  Matches on the following criteria:

  1. Only matches if the activities are on the same date
  2. Only matches if activities are of the same type (example: "Run" or "Ride")
  3. If multiple activities match, it scores the activities based on distance, duration, and external_id

  Returns nil if no activities match

  ## Examples

  iex> get_closest_activity(user, matching_activity)
  %Activity{}

  iex> get_closest_activity(user, no_match_activity)
  null

  """
  def get_closest_activity(%User{} = user, %{} = activity) do
    case Activities.fetch_activity_by_external_id(activity.external_id) do
      {:ok, activity} ->
        activity

      _ ->
        get_closest_pending_activity(user, activity)
    end
  end

  defp get_closest_pending_activity(user, activity) do
    date = Timex.to_date(activity.start_at_local)

    user
    |> Activities.get_pending_activities_by_date(date)
    |> Enum.filter(&(&1.type == activity.type))
    |> Enum.sort(fn a, b -> match_score(a, activity) > match_score(b, activity) end)
    |> List.first()
  end

  defp match_score(planned_activity, activity) do
    pending_score(planned_activity) +
      distance_match(planned_activity, activity) +
      duration_match(planned_activity, activity)
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

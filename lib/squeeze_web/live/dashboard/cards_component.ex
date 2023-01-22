defmodule SqueezeWeb.Dashboard.CardsComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.Distances

  import Number.Percentage, only: [number_to_percentage: 2]

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:personal_record, personal_record(assigns))
     |> assign(:improvement_amount, improvement_amount(assigns))}
  end

  def weekly_distance(%{activity_summaries: summaries, current_user: user}) do
    date = Timex.now()
    |> Timex.to_datetime(user.user_prefs.timezone)
    |> Timex.beginning_of_week()

    distance = summaries
    |> Enum.filter(&(Timex.after?(&1.start_at_local, date) && String.contains?(&1.type, "Run")))
    |> Enum.map(&(&1.distance))
    |> Enum.sum()

    imperial = user.user_prefs.imperial

    "#{Distances.to_float(distance, imperial: imperial)} #{Distances.label(imperial: imperial)}"
  end

  def last_week_distance(%{activity_summaries: summaries, current_user: user}) do
    start_date = Timex.now()
    |> Timex.to_datetime(user.user_prefs.timezone)
    |> Timex.shift(weeks: -1)
    |> Timex.beginning_of_week()

    end_date = start_date |> Timex.end_of_week()

    distance = summaries
    |> Enum.filter(&(Timex.between?(&1.start_at_local, start_date, end_date) && String.contains?(&1.type, "Run")))
    |> Enum.map(&(&1.distance))
    |> Enum.sum()

    imperial = user.user_prefs.imperial

    "#{Distances.to_float(distance, imperial: imperial)} #{Distances.label(imperial: imperial)}"
  end

  def latest_activity(%{activity_summaries: summaries}) do
    List.first(summaries)
  end

  def activity_name(%{current_user: user} = assigns) do
    latest = latest_activity(assigns)
    cond do
      latest.distance > 0 -> "#{format_distance(latest.distance, user.user_prefs)} #{latest.type}"
      latest.duration > 0 -> "#{format_duration(latest.duration)} #{latest.type}"
      true -> latest.type
    end
  end

  defp personal_record(%{race_goal: nil}), do: nil
  defp personal_record(%{current_user: user, race_goal: race_goal}) do
    user.user_prefs.personal_records
    |> Enum.reject(&(is_nil(&1.duration)))
    |> Enum.find(&(&1.distance == race_goal.distance))
  end

  defp improvement_amount(%{race_goal: nil}), do: nil
  defp improvement_amount(%{race_goal: race_goal} = assigns) do
    case personal_record(assigns) do
      %{duration: pr_duration}
      when not is_nil(pr_duration) and not is_nil(race_goal.duration) ->
        (pr_duration - race_goal.duration) / pr_duration * 100
      _ -> nil
    end
  end
end

defmodule SqueezeWeb.Dashboard.CardsComponent do
  use SqueezeWeb, :live_component

  alias Squeeze.Accounts.User
  alias Squeeze.Distances

  def improvement_amount(%User{} = user), do: User.improvement_amount(user)

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
end

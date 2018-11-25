defmodule SqueezeWeb.DashboardView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.Event
  alias Squeeze.Distances

  def title(_page, _assigns) do
    "Dashboard"
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def race_name(user) do
    distance = user.user_prefs.distance
    %{name: name} = Distances.from_meters(distance)
    name
  end

  def improvement_amount(%User{user_prefs: %{personal_record: nil}}), do: nil
  def improvement_amount(%User{user_prefs: prefs}) do
    personal_record = prefs.personal_record
    percent = abs(personal_record - prefs.duration) / personal_record * 100
    "#{Decimal.round(Decimal.new(percent), 1)}%"
  end

  def format_goal(user) do
    user.user_prefs.duration
    |> format_duration()
  end

  def race_date(%User{user_prefs: %{race_date: date}}) do
    date
    |> Timex.format!("%b %d", :strftime)
  end

  def relative_date(user) do
    user.user_prefs.race_date
    |> relative_time()
  end

  def format_event(nil), do: "Rest"
  def format_event(%Event{} = event) do
    event.name
  end

  def todays_workout(events) do
    events
    |> List.first()
    |> format_event()
  end

  def next_workout(events) when length(events) > 2 do
    event = Enum.at(events, 1)
    "Today's next workout: #{format_event(event)}"
  end

  def next_workout(events) do
    event = events |> List.last()
    "Tomorrow's workout: #{format_event(event)}"
  end

  def weekly_distance(activities) do
    today = Date.utc_today()
    date = Date.add(today, -7)
    activities
    |> Enum.filter(fn(x) -> Timex.after?(x.start_at, date) end)
    |> Enum.map(&(&1.distance))
    |> Enum.sum()
  end

  def weekly_milage(activities) do
    meters = activities |> weekly_distance()
    meters / Distances.mile_in_meters
  end
end

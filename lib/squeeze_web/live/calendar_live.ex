defmodule SqueezeWeb.CalendarLive do
  use SqueezeWeb, :live_view

  @moduledoc """
  This is the module for the calendar live view
  """

  import Squeeze.TimeHelper, only: [today: 1, to_date: 2]

  alias Squeeze.Accounts.User
  alias Squeeze.Calendar
  alias Squeeze.Dashboard
  alias Squeeze.Races

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket = assign(socket,
      page_title: "Calendar",
      current_user: user
    )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    user = socket.assigns.current_user
    date = parse_date(user, params["date"])
    dates = Calendar.visible_dates(date, "month")

    socket = assign(socket,
      date: date,
      dates: dates,
      page_title: Timex.format!(date, "%B %Y", :strftime),
      activities_by_date: activities_by_date(user, dates),
      race_goals_by_date: race_goals_by_date(user, dates)
    )

    {:noreply, socket}
  end

  def date_label(date, user) do
    class_names = if today(user) == date do
      "date-label d-inline border-bottom border-primary"
    else
      "date-label"
    end

    content_tag(:div, class: class_names, data: [date: format_date(date)]) do
      date_label_content(date)
    end
  end

  def weeks(%{dates: dates}) do
    dates
    |> Enum.with_index()
    |> Enum.group_by(fn({_, idx}) -> div(idx, 7) end, fn({v, _}) -> v end)
  end

  def activities_in_dates(dates, %{activities_by_date: activities_map}) do
    dates
    |> Enum.flat_map(&(Map.get(activities_map, &1, [])))
  end

  def activities_in_dates(user, activities, dates) do
    activities
    |> Enum.filter(&(Enum.member?(dates, activity_date(user, &1))))
  end

  def format_date(date), do: Timex.format!(date, "{YYYY}-{0M}-{0D}")

  def next(date), do: date |> Timex.shift(months: 1) |> format_date()

  def prev(date), do: date |> Timex.shift(months: -1) |> format_date()

  defp activities_by_date(user, dates) do
    user
    |> Dashboard.list_activities(dates)
    |> Enum.reduce(%{}, fn(x, acc) ->
      date = x.start_at_local |> Timex.to_date()
      list = Map.get(acc, date, [])
      Map.put(acc, date, [x | list])
    end)
  end

  def race_goals_by_date(user, dates) do
    Races.list_race_goals(user, dates)
    |> Enum.reduce(%{}, fn(x, acc) ->
      date = x.race.start_date |> Timex.to_date()
      list = Map.get(acc, date, [])
      Map.put(acc, date, [x | list])
    end)
  end

  defp parse_date(%User{} = user, nil), do: today(user)
  defp parse_date(%User{} = user, date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      {:error, _} -> parse_date(user, nil)
    end
  end

  defp date_label_content(date) do
    if date.day == 1 do
      Timex.format!(date, "%b %-d", :strftime)
    else
      date.day
    end
  end

  defp activity_date(user, activity) do
    activity.planned_date || to_date(user, activity.start_at)
  end
end
